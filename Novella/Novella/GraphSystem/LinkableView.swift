//
//  LinkableView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class LinkableView: NSView {
	// MARK: - - Constants -
	static let OUTPUTS_OFFSET_X: CGFloat = 6.0
	
	// MARK: - - Identifiers -
	static let HIT_IGNORE_TAG: Int = 10
	static let HIT_NIL_TAG: Int = 11
	
	// MARK: - - Variables -
	private var _nvLinkable: NVObject
	internal var _graphView: GraphView
	private var _isPrimed: Bool
	private var _isSelected: Bool
	private let _nameLabel: NSTextField
	//
	private var _clickGesture: NSClickGestureRecognizer?
	private var _doubleClickGesture: NSClickGestureRecognizer?
	private var _ctxGesture: NSClickGestureRecognizer?
	private var _panGesture: NSPanGestureRecognizer?
	//
	private var _outputs: [PinView]
	private var _outputsBoard: PinBoard
	//
	private var _trashMode: Bool
	//
	private var _contextMenu: NSMenu
	private var _contextItemAddLink: NSMenuItem
	private var _contextItemAddBranch: NSMenuItem
	private var _contextItemTrash: NSMenuItem
	
	// MARK: - - Properties -
	public var Outputs: [PinView] {
		get{ return _outputs }
	}
	public var Trashed: Bool {
		get{ return _trashMode }
		set{
			_trashMode = newValue
			_outputs.forEach{$0.TrashMode = newValue}
			onTrashed()
			redraw()
		}
	}
	
	override var wantsDefaultClipping: Bool {
		return false
	}
	
	// MARK: - - Initialization -
	init(frameRect: NSRect, nvLinkable: NVObject, graphView: GraphView) {
		self._nvLinkable = nvLinkable
		self._graphView = graphView
		self._isPrimed = false
		self._isSelected = false
		//
		self._nameLabel = NSTextField(labelWithString: "?")
		self._nameLabel.tag = LinkableView.HIT_IGNORE_TAG
		self._nameLabel.textColor = NSColor.fromHex("#f2f2f2")
		self._nameLabel.font = NSFont.systemFont(ofSize: 42.0, weight: .ultraLight)
		//
		self._clickGesture = nil
		self._doubleClickGesture = nil
		self._ctxGesture = nil
		self._panGesture = nil
		//
		self._outputs = []
		self._outputsBoard = PinBoard()
		//
		self._trashMode = false
		//
		self._contextMenu = NSMenu()
		self._contextItemAddLink = NSMenuItem(title: "Add Link", action: #selector(LinkableView.onContextAddLink), keyEquivalent: "")
		self._contextItemAddBranch = NSMenuItem(title: "Add Branch", action: #selector(LinkableView.onContextAddBranch), keyEquivalent: "")
		self._contextItemTrash = NSMenuItem(title: "Trash", action: #selector(LinkableView.onContextTrash), keyEquivalent: "")
		super.init(frame: frameRect)
		
		// set up context menu
		_contextMenu.autoenablesItems = false
		_contextMenu.addItem(_contextItemAddLink)
		_contextMenu.addItem(_contextItemAddBranch)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_contextItemTrash)
		
		// add shadow
		wantsLayer = true
		layer?.masksToBounds = false
//		self.shadow = NSShadow()
//		self.layer?.shadowOpacity = 0.6
//		self.layer?.shadowColor = NSColor.black.cgColor
//		self.layer?.shadowOffset = NSMakeSize(3, -1)
//		self.layer?.shadowRadius = 5.0
		
		self.addSubview(_outputsBoard)
		
		// name label
		setLabelString(str: "?")
		self.addSubview(self._nameLabel)
		
		// primary click recognizer
		_clickGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onClick))
		_clickGesture!.buttonMask = 0x1 // "primary click"
		_clickGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_clickGesture!)
		// double click recognizer
		_doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onDoubleClick))
		_doubleClickGesture!.buttonMask = 0x1 // "primary click"
		_doubleClickGesture?.numberOfClicksRequired = 2
		self.addGestureRecognizer(_doubleClickGesture!)
		// context click recognizer
		_ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onContextClick))
		_ctxGesture!.buttonMask = 0x2 // "secondary click"
		_ctxGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_ctxGesture!)
		// pan regoznizer
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(LinkableView.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkableView::init(coder) not implemented.")
	}
	
	// MARK: - - Properties -
	var Linkable: NVObject {
		get{ return _nvLinkable }
	}
	var IsPrimed: Bool {
		get{ return _isPrimed }
	}
	var IsSelected: Bool {
		get{ return _isSelected }
	}
	
	// MARK: - - Functions -
	@objc private func onContextAddLink() {
		let link = _graphView.Manager.makeLink(origin: self.Linkable)
		do { try _graphView.NovellaGraph.add(link: link) } catch {
			fatalError("Tried to add a new link but couldn't add it to this graph.")
		}
	}
	@objc private func onContextAddBranch() {
		let link = _graphView.Manager.makeBranch(origin: self.Linkable)
		do{ try _graphView.NovellaGraph.add(link: link) } catch {
			fatalError("Tried to add a new branch but couldn't add it to this graph.")
		}
	}
	@objc private func onContextTrash() {
		Linkable.InTrash ? Linkable.untrash() : Linkable.trash()
	}
	
	func removeOutput(pin: PinView) {
		if let idx = _outputs.index(of: pin) {
			_outputs.remove(at: idx)
			pin.removeFromSuperview()
			
			layoutPins()
		}
	}
	
	private func onTrashed() {
		_contextItemAddLink.isEnabled = !_trashMode
		_contextItemAddBranch.isEnabled = !_trashMode
		_contextItemTrash.title = _trashMode ? "Untrash" : "Trash"
	}
	
	func setLabelString(str: String) {
		_nameLabel.stringValue = str
		self._nameLabel.sizeToFit()
		self._nameLabel.frame.origin = NSMakePoint(self.frame.width/2 - self._nameLabel.frame.width/2, self.frame.height/2 - self._nameLabel.frame.height/2)
	}
	
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	// MARK: Hit Test
	override func hitTest(_ point: NSPoint) -> NSView? {
		// point is in the superview's coordinate system
		// manually check each subview's bounds (if i want to do something similar i'd need to override their hittest and call it here)
		for sub in subviews {
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				// return the node itself if a subview has the ignore tag (this is used for things like overlaying labels)
				if sub.tag == LinkableView.HIT_IGNORE_TAG {
					return self
				}
				if sub.tag == LinkableView.HIT_NIL_TAG {
					continue // just don't do anything with the view
				}
				return sub
			}
		}
		
		// check out local widget's bounds for a mouse click
		if NSPointInRect(superview!.convert(point, to: self), widgetRect()) {
			return self
		}
		
		// nuttin'
		return nil
	}
	
	// MARK: Gesture Callbacks
	@objc private func onClick(gesture: NSGestureRecognizer) {
		_graphView.onClickLinkable(node: self, gesture: gesture)
	}
	@objc private func onDoubleClick(gesture: NSGestureRecognizer) {
		if _trashMode { return }
		_graphView.onDoubleClickLinkable(node: self, gesture: gesture)
	}
	@objc private func onContextClick(gesture: NSGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		_graphView.onPanLinkable(node: self, gesture: gesture)
	}
	
	// MARK: Virtual Functions
	func widgetRect() -> NSRect {
		return NSMakeRect(0.0, 0.0, 64.0, 64.0)
	}
	func onMove() {
		print("LinkableView::onMove() should be overridden.")
	}
	func bgTopColor() -> NSColor {
		print("LinkableView::bgTopColor() should be overridden.")
		return NSColor.black
	}
	func bgBottomColor() -> NSColor {
		print("LinkableView::bgBottomColor() should be overridden.")
		return NSColor.black
	}
	
	// MARK: Priming/Selection
	func select() {
		_isSelected = true
		_isPrimed = false
		setNeedsDisplay(bounds)
	}
	func deselect() {
		_isSelected = false
		_isPrimed = false
		setNeedsDisplay(bounds)
	}
	func prime() {
		_isSelected = false
		_isPrimed = true
		setNeedsDisplay(bounds)
	}
	func unprime() {
		_isSelected = false
		_isPrimed = false
		setNeedsDisplay(bounds)
	}
	
	// MARK: Movement
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_graphView.updateCurves()
	}
	
	// MARK: Outputs
	func addOutput(pin: PinView) {
		_outputs.append(pin)
		self.addSubview(pin)
		layoutPins()
		sizeToFitSubviews() // subviews cannot be interacted with if they are out of the bounds of the superview, so resize
		
		setNeedsDisplay(bounds)
	}
	private func layoutPins() {
		if _outputs.isEmpty {
			_outputsBoard.frame = NSRect.zero // remove outputs board (size to zero)
			_outputsBoard.setNeedsDisplay(_outputsBoard.bounds)
			return
		}
		
		// set first pin at origin
		_outputs[0].frame.origin = CGPoint.zero
		
		// align all other views accordingly
		let spacing: CGFloat = 5.0
		var lastY = _outputs[0].bounds.height
		if _outputs.count > 1 {
			for i in 1..<_outputs.count {
				_outputs[i].frame.origin = NSMakePoint(0.0, lastY + spacing)
				lastY += _outputs[i].bounds.height + spacing
			}
		}
		
		// calculate center Y (since at origin can just half height of stack, i.e. last element)
		let centerY = _outputs.last!.frame.maxY * 0.5
		
		// calculate difference between the stack's center and the widget's rect's center
		let wRect = widgetRect()
		let yDiff = (wRect.height*0.5) - centerY
		
		// move all views up by the diff and set fixed X
		for curr in _outputs {
			curr.frame.origin.y += yDiff
			curr.frame.origin.x = wRect.width + LinkableView.OUTPUTS_OFFSET_X
		}
		
		// set bounds frame and adjust it for the offset
		_outputsBoard.frame = boundsOf(views: _outputs)
		let border = NSMakeSize(6.0, 8.0)
		_outputsBoard.frame.size.width += border.width
		_outputsBoard.frame.size.height += border.height
		_outputsBoard.frame.origin.x -= border.width * 0.5
		_outputsBoard.frame.origin.y -= border.height * 0.5
		_outputsBoard.setNeedsDisplay(_outputsBoard.frame)
	}
	private func boundsOf(views: [NSView]) -> NSRect {
		var minX = CGFloat.infinity
		var maxX = -CGFloat.infinity
		var minY = CGFloat.infinity
		var maxY = -CGFloat.infinity
		for curr in views {
			minX = curr.frame.minX < minX ? curr.frame.minX : minX
			maxX = curr.frame.maxX > maxX ? curr.frame.maxX : maxX
			minY = curr.frame.minY < minY ? curr.frame.minY : minY
			maxY = curr.frame.maxY > maxY ? curr.frame.maxY : maxY
		}
		return NSMakeRect(minX, minY, maxX - minX, maxY - minY)
	}
	private func sizeToFitSubviews() {
		var w: CGFloat = frame.width
		var h: CGFloat = frame.height
		for sub in subviews {
			let sw = sub.frame.origin.x + sub.frame.width
			let sh = sub.frame.origin.y + sub.frame.height
			w = max(w, sw)
			h = max(h, sh)
		}
		self.frame.size = NSMakeSize(w, h)
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// create drawing rect for this object
			let drawingRect = widgetRect()
			
			// draw background gradient
			let bgRadius = Settings.graph.nodes.roundness
			var path = NSBezierPath(roundedRect: drawingRect, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgColors = [Trashed ? bgTopColor().withSaturation(Settings.graph.trashedSaturation).cgColor : bgTopColor().cgColor,
											Trashed ? bgBottomColor().withSaturation(Settings.graph.trashedSaturation).cgColor : bgBottomColor().cgColor]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: drawingRect.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			
			// draw outline (inset)
			let selectedRect = drawingRect
			path = NSBezierPath(roundedRect: selectedRect, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip() // clip to avoid edge artifacting
			path.lineWidth = Settings.graph.nodes.outlineWidth
			Trashed ? Settings.graph.nodes.outlineColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.outlineColor.setStroke()
			path.stroke()
			
			// draw primed indicator
			if IsPrimed {
				let insetRect = drawingRect
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = Settings.graph.nodes.primedWidth
				Trashed ? Settings.graph.nodes.primedColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.primedColor.setStroke()
				path.lineJoinStyle = .miterLineJoinStyle
				path.stroke()
			}
			
			// draw selection indicator
			if IsSelected {
				let insetRect = drawingRect
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = Settings.graph.nodes.selectedWidth
				Trashed ? Settings.graph.nodes.selectedColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.selectedColor.setStroke()
				path.stroke()
			}
			
			context.restoreGState()
		}
	}
}
