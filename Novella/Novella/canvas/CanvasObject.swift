//
//  CanvasObject.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

// has to be objc due to some compiler bug according to StackOverflow (lost the link)
@objc protocol CanvasObjectDelegate: AnyObject {
	func canvasObjectMoved(obj: CanvasObject)
}

class CanvasObject: NSView {
	enum LayoutStyle {
		case standard
		case iconOnly
	}
	
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
			stateDidChange()
		}
	}
	private var _delegates = NSHashTable<CanvasObjectDelegate>.weakObjects()
	
	private let _bgLayer: CAGradientLayer
	private let _outlineLayer: CAShapeLayer
	private let _labelLayer: CATextLayer
	private let _parallelLayer: CAShapeLayer
	private let _entryLayer: CAShapeLayer
	
	init(canvas: Canvas, frame: NSRect, linkable: NVLinkable) {
		self.Linkable = linkable
		self._canvas = canvas
		self._lastPanPos = CGPoint.zero
		self.ContextMenu = NSMenu()
		self._bgLayer = CAGradientLayer()
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
		_bgLayer.frame = mainFrame
		_bgLayer.cornerRadius = (max(_bgLayer.frame.width, _bgLayer.frame.height) * 0.5) * shapeRoundness()
		_bgLayer.colors = [lighterColor.cgColor, darkerColor.cgColor]
		_bgLayer.startPoint = NSPoint.zero
		_bgLayer.endPoint = NSMakePoint(0.0, 1.0)
		_bgLayer.locations = [0.0, 0.3]
		// outline layer
		_outlineLayer.fillColor = nil
		_outlineLayer.path = NSBezierPath(roundedRect: _bgLayer.frame, xRadius: _bgLayer.cornerRadius, yRadius: _bgLayer.cornerRadius).cgPath
		_outlineLayer.strokeColor = darkerColor.withAlphaComponent(0.4).cgColor
		updateOutlineWidth()
		layer?.addSublayer(_outlineLayer) // add before bg so it's below it
		layer?.addSublayer(_bgLayer)
		
		// setup the main layout (BG and outline are always present)
		switch layoutStyle() {
		case .standard:
			setupStyleIconFlagText()
		case .iconOnly:
			setupStyleIconOnly()
		}
		
		// parallel layer
		if hasParallelLayer() {
			let parallelSize: CGFloat = 15.0
			_parallelLayer.path = NSBezierPath(ovalIn: NSMakeRect(0, 0, parallelSize, parallelSize)).cgPath
			_parallelLayer.fillColor = primaryColor.cgColor
			_parallelLayer.strokeColor = NSColor.fromHex("#f2f2f2").withAlphaComponent(0.75).cgColor
			_parallelLayer.lineWidth = 2.0
			_parallelLayer.frame.setCenter(NSMakePoint(mainFrame.minX - parallelSize*0.5, mainFrame.maxY - parallelSize*0.5))
			_parallelLayer.opacity = 0.0
			layer?.addSublayer(_parallelLayer)
		}
		
		// entry layer
		if hasEntryLayer() {
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
		}
		
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
	
	// MARK: - Styling/Drawing
	private func setupStyleIconFlagText() {
		let mainFrame = objectRect()
		
		// flag layer
		let flagSize: CGFloat = 0.3
		let flagLayer = CAShapeLayer()
		let flagRect = NSMakeRect(0, 0, mainFrame.width * flagSize, mainFrame.height)
		flagLayer.path = NSBezierPath.withRoundedCorners(rect: flagRect, byRoundingCorners: [.minXMinY, .minXMaxY], withRadius: _bgLayer.cornerRadius, includingEdges: [.all]).cgPath
		flagLayer.fillColor = mainColor().cgColor
		layer?.addSublayer(flagLayer)
		
		// type icon layer
		let iconLayer = CALayer()
		let iconSize = flagRect.width * 0.55 // square as a percentage of the flag
		iconLayer.frame = NSMakeRect(0, 0, iconSize, iconSize)
		iconLayer.frame.setCenter(flagRect.center)
		iconLayer.contents = iconImage()
		iconLayer.contentsRect = NSMakeRect(0, 0, 1, 1)
		iconLayer.contentsGravity = .resizeAspectFill
		layer?.addSublayer(iconLayer)
		
		// label layer
		let labelOffset: CGFloat = 4.0
		_labelLayer.string = "Alan please change this."
		_labelLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
		_labelLayer.font = NSFont.systemFont(ofSize: 1.0, weight: .light)
		_labelLayer.fontSize = 8.0
		_labelLayer.foregroundColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.75).cgColor
		_labelLayer.frame.size = _labelLayer.preferredFrameSize()
		_labelLayer.frame.origin = NSMakePoint(flagRect.maxX + labelOffset, flagRect.midY - _labelLayer.frame.height * 0.5)
		_labelLayer.frame.size.width = mainFrame.width - _labelLayer.frame.minX
		_labelLayer.truncationMode = .middle
		layer?.addSublayer(_labelLayer)
	}
	
	private func setupStyleIconOnly() {
		let mainFrame = objectRect()
		
		let iconLayer = CALayer()
		let iconSize = (mainFrame.width * 0.75) * 0.55
		iconLayer.frame = NSMakeRect(0, 0, iconSize, iconSize)
		iconLayer.frame.setCenter(mainFrame.center)
		iconLayer.contents = iconImage()
		iconLayer.contentsRect = NSMakeRect(0, 0, 1, 1)
		iconLayer.contentsGravity = .resizeAspectFill
		layer?.addSublayer(iconLayer)
	}
	
	private func updateOutlineWidth() {
		let width: CGFloat
		switch CurrentState {
		case .normal:
			width = 4.0
		case .primed:
			width = 8.0
		case .selected:
			width = 12.0
		}
		_outlineLayer.lineWidth = width
	}
	
	func setParallelLayer(state: Bool) {
		_parallelLayer.opacity = state ? 1.0 : 0.0
	}
	
	func setEntryLayer(state: Bool) {
		_entryLayer.opacity = state ? 1.0 : 0.0
	}
	
	// MARK: - Delegates
	func add(delegate: CanvasObjectDelegate) {
		_delegates.add(delegate)
	}
	func remove(delegate: CanvasObjectDelegate) {
		_delegates.remove(delegate)
		// not strictly necesary as NSHashTable removes nil values from allObjects
	}
	
	// MARK: - Public
	func move(to: CGPoint) {
		frame.origin = to
		didMove()
		_delegates.allObjects.forEach{$0.canvasObjectMoved(obj: self)}
	}
	
	// MARK: - Internal Callbacks
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
	
	// MARK: - Virtual Functions -
	// MARK: Styling/Drawing
	func objectRect() -> NSRect {
		// rect within the object's bounds that are the "main" object (used mostly for when the frame is expanded but the object shouldn't change size)
		return bounds
	}
	
	func shapeRoundness() -> CGFloat {
		// roundness of background where 0 is square and 1 is circle
		return 0.075
	}
	
	func layoutStyle() -> LayoutStyle {
		// the layout (beyond the bg) of the object; used for different drawing styles by derivatives
		return .standard
	}
	
	func hasParallelLayer() -> Bool {
		// does the node have a parallel layer? false is mostly for optimization (does not add it)
		return true
	}
	
	func hasEntryLayer() -> Bool {
		// does the node have an entry layer? false is mostly for optimization (does not add it)
		return true
	}
	
	func mainColor() -> NSColor {
		// primary color of the node
		return NSColor.fromHex("#FF00FF")
	}
	
	func labelString() -> String {
		// for derived classes to return the model object's label as everything has this
		return "Alan, please implement this."
	}
	
	func iconImage() -> NSImage? {
		return NSImage(named: NSImage.cautionName)
	}
	
	// MARK: (Internal) Callbacks
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
	
	// MARK: (Other) Callbacks
	func didMove() {
		// literal movement on the canvas, i.e. self.frame.origin changed
	}
	
	func stateDidChange() {
		updateOutlineWidth()
	}

	func reloadData() {
		_labelLayer.string = labelString()
	}
}
