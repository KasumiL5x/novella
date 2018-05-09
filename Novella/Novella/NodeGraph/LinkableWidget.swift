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
			NSTrackingArea.Options.mouseEnteredAndExited
		]
		_trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(_trackingArea!)
	}
	
	func addOutput(pin: LinkPinView?=nil) {
		if pin == nil {
			// TODO: add new one and link from this to nothing (or cursor etc.)
		} else {
			
			// auto-position pin
			var pos = CGPoint.zero
			pos.x = self.frame.width - (pin!.frame.width * 0.5)
			pos.y = self.frame.height - (pin!.frame.height * 2.0)
			pos.y -= CGFloat(_outputs.count) * (pin!.frame.height * 1.5)
			pin!.frame.origin = pos
			
			_outputs.append(pin!)
			self.addSubview(pin!)
		}
	}
	
//	func addOutputPin() {
//		let pin = OutputPin(owner: self)
//
//		var pos = CGPoint.zero
//		pos.x = self.frame.width - (pin.frame.width * 0.5)
//		pos.y = self.frame.height - (pin.frame.height * 2.0)
//		pos.y -= CGFloat(_outputs.count) * (pin.frame.height * 1.5)
//		pin.frame.origin = pos
//
//		_outputs.append(pin)
//		self.addSubview(pin)
//
//		// TODO: Resize bounds of this area or something?
//	}
	
	// MARK: Functions for derived classes to override.
	func onMove() {
		print("LinkableWidget::onMove() should be overridden.")
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
	
	override func mouseEntered(with event: NSEvent) {
		if !_isSelected {
			primeForSelect()
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		if _isPrimedForSelection {
			unprimeForSelect()
		}
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
