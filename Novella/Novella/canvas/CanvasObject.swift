//
//  CanvasObject.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

// has to be objc due to some compiled bug according to SO
@objc protocol CanvasObjectDelegate: AnyObject {
	func canvasObjectMoved(obj: CanvasObject)
}

class CanvasObject: NSView {
	static let Roundness: CGFloat = 0.075
	static let NormalOutlineSize: CGFloat = 4.0
	static let PrimedOutlineSize: CGFloat = 8.0
	static let SelectedOutlineSize: CGFloat = 12.0
	static let FlagSize: CGFloat = 0.3
	static let IconSize: CGFloat = 0.55
	static let LabelOffset: CGFloat = 4.0
	
	enum State {
		case normal
		case primed
		case selected
	}
	
	override var tag: Int {
		return 0 // anything not -1
	}
	
	let Linkable: NVLinkable
	private(set) var _canvas: Canvas
	private var _lastPanPos: CGPoint
	var ContextMenu: NSMenu
	var CurrentState: State = .normal {
		didSet {
			onStateChanged()
		}
	}
	private var _delegates = NSHashTable<CanvasObjectDelegate>.weakObjects()
	
	private let _outlineLayer: CAShapeLayer
	private let _labelLayer: CATextLayer
	private let _parallelLayer: CAShapeLayer
	private let _entryLayer: CAShapeLayer
	
	init(canvas: Canvas, frame: NSRect, linkable: NVLinkable) {
		self.Linkable = linkable
		self._canvas = canvas
		self._lastPanPos = CGPoint.zero
		self.ContextMenu = NSMenu()
		self._outlineLayer = CAShapeLayer()
		self._labelLayer = CATextLayer()
		self._parallelLayer = CAShapeLayer()
		self._entryLayer = CAShapeLayer()
		super.init(frame: frame)
		
		self.frame = objectRect()
		let mainFrame = objectRect()
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// object colors
		let primaryColor = mainColor()
		let lighterColor = primaryColor.lighter(removeSaturation: 0.15)
		let darkerColor = lighterColor.darker(removeValue: 0.04)

		// main background layer
		let bgGradient = CAGradientLayer()
		bgGradient.frame = mainFrame
		bgGradient.cornerRadius = (max(bgGradient.frame.width, bgGradient.frame.height) * 0.5) * CanvasObject.Roundness
		bgGradient.colors = [lighterColor.cgColor, darkerColor.cgColor]
		bgGradient.startPoint = NSPoint.zero
		bgGradient.endPoint = NSMakePoint(0.0, 1.0)
		bgGradient.locations = [0.0, 0.3]
		// outline layer
		_outlineLayer.fillColor = nil
		_outlineLayer.path = NSBezierPath(roundedRect: bgGradient.frame, xRadius: bgGradient.cornerRadius, yRadius: bgGradient.cornerRadius).cgPath
		_outlineLayer.strokeColor = darkerColor.withAlphaComponent(0.4).cgColor //99b1c8
		setupOutlineLayer()
		layer?.addSublayer(_outlineLayer) // add before bg so it's below it
		layer?.addSublayer(bgGradient)
		
		// flag layer
		let flagLayer = CAShapeLayer()
		let flagRect = NSMakeRect(0, 0, mainFrame.width * CanvasObject.FlagSize, mainFrame.height)
		flagLayer.path = NSBezierPath.withRoundedCorners(rect: flagRect, byRoundingCorners: [.minXMinY, .minXMaxY], withRadius: bgGradient.cornerRadius, includingEdges: [.all]).cgPath
		flagLayer.fillColor = primaryColor.cgColor
		layer?.addSublayer(flagLayer)
		
		// type icon layer
		let iconLayer = CALayer()
		let typeIconSize = flagRect.width * CanvasObject.IconSize // square as a percentage of the flag
		iconLayer.frame = NSMakeRect(0, 0, typeIconSize, typeIconSize)
		iconLayer.frame.setCenter(flagRect.center)
		iconLayer.contents = NSImage(named: NSImage.cautionName)
		iconLayer.contentsRect = NSMakeRect(0, 0, 1, 1)
		iconLayer.contentsGravity = .resizeAspectFill
		layer?.addSublayer(iconLayer)
		
		// label layer
		_labelLayer.string = "Alan please change this."
		_labelLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
		_labelLayer.font = NSFont.systemFont(ofSize: 1.0, weight: .light)
		_labelLayer.fontSize = 8.0
		_labelLayer.foregroundColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.75).cgColor
		_labelLayer.frame.size = _labelLayer.preferredFrameSize()
		_labelLayer.frame.origin = NSMakePoint(flagRect.maxX + CanvasObject.LabelOffset, flagRect.midY - _labelLayer.frame.height * 0.5)
		_labelLayer.frame.size.width = mainFrame.width - _labelLayer.frame.minX
		_labelLayer.truncationMode = .middle
		layer?.addSublayer(_labelLayer)
		
		// parallel layer
		let parallelSize: CGFloat = 15.0
		_parallelLayer.path = NSBezierPath(ovalIn: NSMakeRect(0, 0, parallelSize, parallelSize)).cgPath
		_parallelLayer.fillColor = primaryColor.cgColor
		_parallelLayer.strokeColor = NSColor.fromHex("#f2f2f2").withAlphaComponent(0.75).cgColor
		_parallelLayer.lineWidth = 2.0
		_parallelLayer.frame.setCenter(NSMakePoint(mainFrame.minX - parallelSize*0.5, mainFrame.maxY - parallelSize*0.5))
		_parallelLayer.opacity = 0.0
		layer?.addSublayer(_parallelLayer)
		
		// entry layer
		let entryArrowWidth: CGFloat = 35.0
		let entryArrowSize: CGFloat = 0.2
		let entryArrowHeight: CGFloat = 0.5
		let entryPath = NSBezierPath()
		entryPath.move(to: NSMakePoint(mainFrame.minX - entryArrowWidth, mainFrame.midY))
		entryPath.line(to: NSMakePoint(mainFrame.minX, mainFrame.midY))
		entryPath.move(to: NSMakePoint(mainFrame.minX - (entryArrowWidth * entryArrowSize), mainFrame.midY + ((mainFrame.maxY - mainFrame.midY) * entryArrowHeight)))
		entryPath.line(to: NSMakePoint(mainFrame.minX, mainFrame.midY))
		entryPath.line(to: NSMakePoint(mainFrame.minX - (entryArrowWidth * entryArrowSize), mainFrame.midY - ((mainFrame.midY - mainFrame.minY) * entryArrowHeight)))
		_entryLayer.path = entryPath.cgPath
		_entryLayer.lineCap = .round
		_entryLayer.lineJoin = .bevel
		_entryLayer.fillColor = nil
		_entryLayer.strokeColor = NSColor.fromHex("#FAFAFA").withAlphaComponent(0.8).cgColor
		_entryLayer.lineWidth = 3.0
		_entryLayer.opacity = 0.0
		layer?.addSublayer(_entryLayer)
		
		// gestures
		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onClick))
		clickGesture.buttonMask = 0x1
		clickGesture.numberOfClicksRequired = 1
		addGestureRecognizer(clickGesture)
		//
		let dubGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onDoubleClick))
		dubGesture.buttonMask = 0x1
		dubGesture.numberOfClicksRequired = 2
		addGestureRecognizer(dubGesture)
		//
		let ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onContextClick))
		ctxGesture.buttonMask = 0x2
		ctxGesture.numberOfClicksRequired = 1
		addGestureRecognizer(ctxGesture)
		//
		let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CanvasObject._onPan))
		panGesture.buttonMask = 0x1
		addGestureRecognizer(panGesture)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	private func setupOutlineLayer() {
		let width: CGFloat
		switch CurrentState {
		case .normal:
			width = CanvasObject.NormalOutlineSize
		case .primed:
			width = CanvasObject.PrimedOutlineSize
		case .selected:
			width = CanvasObject.SelectedOutlineSize
		}
		_outlineLayer.lineWidth = width
	}
	
	func add(delegate: CanvasObjectDelegate) {
		_delegates.add(delegate)
	}
	func remove(delegate: CanvasObjectDelegate) {
		_delegates.remove(delegate)
		// not strictly necesary as NSHashTable removes nil values from allObjects
	}
	
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_delegates.allObjects.forEach{$0.canvasObjectMoved(obj: self)}
	}
	
	func setParallelLayer(state: Bool) {
		_parallelLayer.opacity = state ? 1.0 : 0.0
	}
	
	func setEntryLayer(state: Bool) {
		_entryLayer.opacity = state ? 1.0 : 0.0
	}
	
	@objc private func _onClick(gesture: NSClickGestureRecognizer) {
		let append = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
		if append {
			if CurrentState == .selected {
				_canvas.Selection.deselect(self)
			} else {
				_canvas.Selection.select(self, append: true)
			}
		} else {
			_canvas.Selection.select(self, append: false)
		}
		onClick(gesture: gesture)
	}
	@objc private func _onDoubleClick(gesture: NSClickGestureRecognizer) {
		onDoubleClick(gesture: gesture)
	}
	@objc private func _onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(ContextMenu, with: NSApp.currentEvent!, for: self)
		onContextClick(gesture: gesture)
	}
	@objc private func _onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_lastPanPos = gesture.location(in: self)
			if CurrentState != .selected {
				// replace selection if click dragging a non-selected object
				_canvas.Selection.select(self, append: false)
			}
			
		case .changed:
			let currPanPos = gesture.location(in: self)
			let deltaPanPos = currPanPos - _lastPanPos
			_canvas.moveSelection(delta: deltaPanPos)
			
		case .cancelled, .ended:
			break
			
		default:
			break
		}
		
		onPan(gesture: gesture)
	}
	
	//
	// virtual functions

	func onClick(gesture: NSClickGestureRecognizer) {
	}
	func onDoubleClick(gesture: NSClickGestureRecognizer) {
		// send double click notification
		NotificationCenter.default.post(name: NSNotification.Name.nvCanvasObjectDoubleClicked, object: nil, userInfo: [
			"object": self
		])
	}
	func onContextClick(gesture: NSClickGestureRecognizer) {
	}
	func onPan(gesture: NSPanGestureRecognizer) {
	}
	func onMove() {
	}
	func onStateChanged() {
		setupOutlineLayer()
	}
	func mainColor() -> NSColor {
		return NSColor.fromHex("#FF00FF")
	}
	func labelString() -> String {
		// for derived classes to return the model object's label as everything has this
		return "Alan, please implement this."
	}
	func objectRect() -> NSRect {
		 // rect within the object's bounds that are the "main" object (used mostly for when the frame is expanded but the object shouldn't change size)
		return bounds
	}
	func reloadData() {
		_labelLayer.string = labelString()
	}
}
