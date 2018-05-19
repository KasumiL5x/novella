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
	fileprivate var _nvLinkable: NVLinkable
	fileprivate var _graphView: GraphView
	fileprivate var _isPrimed: Bool
	fileprivate var _isSelected: Bool
	//
	fileprivate var _clickGesture: NSClickGestureRecognizer?
	fileprivate var _doubleClickGesture: NSClickGestureRecognizer?
	fileprivate var _ctxGesture: NSClickGestureRecognizer?
	fileprivate var _panGesture: NSPanGestureRecognizer?
	//
	fileprivate var _outputs: [PinView]
	
	// MARK: - - Initialization -
	init(frameRect: NSRect, nvLinkable: NVLinkable, graphView: GraphView) {
		self._nvLinkable = nvLinkable
		self._graphView = graphView
		self._isPrimed = false
		self._isSelected = false
		//
		self._clickGesture = nil
		self._doubleClickGesture = nil
		self._ctxGesture = nil
		self._panGesture = nil
		//
		self._outputs = []
		super.init(frame: frameRect)
		
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
	@objc fileprivate func onClick(gesture: NSGestureRecognizer) {
		_graphView.onClickLinkable(node: self, gesture: gesture)
	}
	@objc fileprivate func onDoubleClick(gesture: NSGestureRecognizer) {
		_graphView.onDoubleClickLinkable(node: self, gesture: gesture)
	}
	@objc fileprivate func onContextClick(gesture: NSGestureRecognizer) {
		_graphView.onContextLinkable(node: self, gesture: gesture)
	}
	@objc fileprivate func onPan(gesture: NSPanGestureRecognizer) {
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
			context.restoreGState()
		}
	}
}
