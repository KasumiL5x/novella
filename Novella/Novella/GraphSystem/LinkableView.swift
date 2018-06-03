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
	// MARK: - - Identifiers -
	static let HIT_IGNORE_TAG: Int = 10
	
	// MARK: - - Variables -
	private var _nvLinkable: NVLinkable
	private var _graphView: GraphView
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
	//
	private var _trashMode: Bool
	
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
	
	// MARK: - - Initialization -
	init(frameRect: NSRect, nvLinkable: NVLinkable, graphView: GraphView) {
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
		//
		self._trashMode = false
		super.init(frame: frameRect)
		
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
	var Linkable: NVLinkable {
		get{ return _nvLinkable }
	}
	var IsPrimed: Bool {
		get{ return _isPrimed }
	}
	var IsSelected: Bool {
		get{ return _isSelected }
	}
	
	// MARK: - - Functions -
	func removeOutput(pin: PinView) {
		if let idx = _outputs.index(of: pin) {
			_outputs.remove(at: idx)
		}
	}
	
	func onTrashed() {
		print("LinkableView::onTrashed() should be overridden.")
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
		if _trashMode { return }
		_graphView.onContextLinkable(node: self, gesture: gesture)
	}
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		_graphView.onPanLinkable(node: self, gesture: gesture)
	}
	
	// MARK: Virtual Functions
	func widgetRect() -> NSRect {
		print("LinkableView::widgetRect() should be overridden.")
		return NSRect.zero
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
		// auto-position
		let wrect = widgetRect()
		var pos = CGPoint.zero
		pos.x = wrect.width - (pin.frame.width * 0.5)
		pos.y = wrect.height - (pin.frame.height * 2.0)
		pos.y -= CGFloat(_outputs.count) * (pin.frame.height * 1.5)
		pin.frame.origin = pos
		
		_outputs.append(pin)
		self.addSubview(pin)
		
		// subviews cannot be interacted with if they are out of the bounds of the superview, so resize
		sizeToFitSubviews()
	}
	func sizeToFitSubviews() {
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
			let outlineInset = Settings.graph.nodes.outlineInset
			let selectedRect = drawingRect.insetBy(dx: outlineInset, dy: outlineInset)
			path = NSBezierPath(roundedRect: selectedRect, xRadius: bgRadius, yRadius: bgRadius)
			context.resetClip()
			path.lineWidth = Settings.graph.nodes.outlineWidth
			Trashed ? Settings.graph.nodes.outlineColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.outlineColor.setStroke()
			path.stroke()
			
			// draw primed indicator
			if IsPrimed {
				let selectedInset = Settings.graph.nodes.primedInset
				let insetRect = drawingRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = Settings.graph.nodes.primedWidth
				Trashed ? Settings.graph.nodes.primedColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.primedColor.setStroke()
				path.stroke()
			}
			
			// draw selection indicator
			if IsSelected {
				let selectedInset = Settings.graph.nodes.selectedInset
				let insetRect = drawingRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = Settings.graph.nodes.selectedWidth
				Trashed ? Settings.graph.nodes.selectedColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : Settings.graph.nodes.selectedColor.setStroke()
				path.stroke()
			}
			
			context.restoreGState()
		}
	}
}
