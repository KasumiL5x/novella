//
//  LinkableWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class LinkableWidget: NSView {
	let _canvas: Canvas
	var _nvLinkable: NVLinkable?
	var _isPrimedForSelection: Bool
	var _isSelected: Bool
	
	var _trackingArea: NSTrackingArea?
	
	var _outputs: [LinkPinView]
	
	init(frame frameRect: NSRect, novellaLinkable: NVLinkable, canvas: Canvas) {
		self._canvas = canvas
		self._nvLinkable = novellaLinkable
		self._isPrimedForSelection = false
		self._isSelected = false
		
		self._outputs = []
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkableWidget::init(coder) not implemented.")
	}
	
	override func updateTrackingAreas() {
		if _trackingArea != nil {
			self.removeTrackingArea(_trackingArea!)
		}
		
		let options: NSTrackingArea.Options = [
			NSTrackingArea.Options.activeInKeyWindow,
			NSTrackingArea.Options.mouseEnteredAndExited,
			NSTrackingArea.Options.mouseMoved
		]
		_trackingArea = NSTrackingArea(rect: widgetRect(), options: options, owner: self, userInfo: nil)
		self.addTrackingArea(_trackingArea!)
	}
	
	func addOutput(pin: LinkPinView?=nil) {
		if pin == nil {
			// TODO: add new one and link from this to nothing (or cursor etc.)
		} else {
			
			// auto-position pin
			let wrect = widgetRect()
			var pos = CGPoint.zero
			pos.x = wrect.width - (pin!.frame.width * 0.5)
			pos.y = wrect.height - (pin!.frame.height * 2.0)
			pos.y -= CGFloat(_outputs.count) * (pin!.frame.height * 1.5)
			
			pin!.frame.origin = pos
			
			_outputs.append(pin!)
			self.addSubview(pin!)
			
			// subviews can't be interacted with if they are beyond the bounds of the superview
			sizeToFitSubviews()
		}
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
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		// manually check each subview's bounds (if i want to do something similar i'd need to override their hittest and call it here)
		for sub in subviews {
			if NSPointInRect(_canvas.convert(point, to: sub), sub.bounds) {
				return sub
			}
		}
		
		// check out local widget's bounds for a mouse click
		if NSPointInRect(_canvas.convert(point, to: self), widgetRect()) {
			return self
		}
		
		// nuttin'
		return nil
	}
	
	// MARK: Functions for derived classes to override.
	func onMove() {
		print("LinkableWidget::onMove() should be overridden.")
	}
	func widgetRect() -> NSRect {
		print("LinkableWidget::widgetRect() should be overridden.")
		return NSRect.zero
	}
	
	// MARK: Selection
	func primeForSelect() {
		_isPrimedForSelection = true
		self.setNeedsDisplay(self.bounds)
	}
	func unprimeForSelect() {
		_isPrimedForSelection = false
		self.setNeedsDisplay(self.bounds)
	}
	func select() {
		_isSelected = true
		self.setNeedsDisplay(self.bounds)
	}
	func deselect() {
		_isSelected = false
		self.setNeedsDisplay(self.bounds)
	}
	
	// private - only use within commands
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_canvas.updateCurves()
	}
	
	override func mouseMoved(with event: NSEvent) {
		// bit of a hack, but ignores this window if the mouse isn't directly over it (https://gist.github.com/eonist/537ae53b86d5fc332fd3)
		let mouseOnThisView = self == window!.contentView!.hitTest(window!.mouseLocationOutsideOfEventStream)
		
		// manually handle equivalent to mouseEntered/mouseExited as we have subviews overlapping this view, which means if
		// the mouse enters through a subview, it won't trigger correctly, and simlar for exit.  This isn't efficient, but it works.
		if mouseOnThisView {
			// handle "enter" condition here as we could move from an overlapping subview which technically means we're already entered and thus won't work
			if !_isSelected {
				primeForSelect()
			}
		} else {
			if _isPrimedForSelection {
				unprimeForSelect()
			}
		}
		
	}
	
	override func mouseEntered(with event: NSEvent) {
	}
	
	override func mouseExited(with event: NSEvent) {

	}
	
	override func mouseDown(with event: NSEvent) {
		_canvas.onMouseDownLinkableWidget(widget: self, event: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		_canvas.onMouseDraggedLinkableWidget(widget: self, event: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		_canvas.onMouseUpLinkableWidget(widget: self, event: event)
	}
	override func rightMouseDown(with event: NSEvent) {
		_canvas.onRightMouseDownLinkableWidget(widget: self, event: event)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
