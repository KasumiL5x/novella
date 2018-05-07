//
//  CanvasWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class CanvasWidget: NSView {
	let _canvas: Canvas
	var _isPrimedForSelection: Bool
	var _isSelected: Bool
	
	var _trackingArea: NSTrackingArea?
	
	init(frame frameRect: NSRect, canvas: Canvas) {
		self._canvas = canvas
		self._isPrimedForSelection = false
		self._isSelected = false
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasWidget::init(coder) not implemented.")
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
	
	// MARK: Functions for derived classes to override.
	func onMove() {
		print("CanvasWidget::onMove() should be overridden.")
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
		_canvas.onMouseDownCanvasWidget(widget: self, event: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		_canvas.onMouseDraggedCanvasWidget(widget: self, event: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		_canvas.onMouseUpCanvasWidget(widget: self, event: event)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
