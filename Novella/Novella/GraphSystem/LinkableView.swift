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
	// MARK: - - Variables -
	fileprivate var _nvLinkable: NVLinkable
	fileprivate var _graphView: GraphView
	fileprivate var _isPrimed: Bool
	fileprivate var _isSelected: Bool
	//
	var _clickGesture: NSClickGestureRecognizer?
	var _ctxGesture: NSClickGestureRecognizer?
	var _panGesture: NSPanGestureRecognizer?
	
	// MARK: - - Initialization -
	init(frameRect: NSRect, nvLinkable: NVLinkable, graphView: GraphView) {
		self._nvLinkable = nvLinkable
		self._graphView = graphView
		self._isPrimed = false
		self._isSelected = false
		self._clickGesture = nil
		self._ctxGesture = nil
		self._panGesture = nil
		super.init(frame: frameRect)
		
		// primary click recognizer
		_clickGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onClick))
		_clickGesture!.buttonMask = 0x1 // "primary click"
		_clickGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_clickGesture!)
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
	@objc fileprivate func onContextClick(gesture: NSGestureRecognizer) {
		_graphView.onContextLinkable(node: self, gesture: gesture)
	}
	@objc fileprivate func onPan(gesture: NSGestureRecognizer) {
		_graphView.onPanLinkable(node: self, gesture: gesture)
	}
	
	// MARK: Virtual Functions
	func widgetRect() -> NSRect {
		print("LinkableView::widgetRect() should be overridden.")
		return NSRect.zero
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
	
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			context.restoreGState()
		}
	}
}
