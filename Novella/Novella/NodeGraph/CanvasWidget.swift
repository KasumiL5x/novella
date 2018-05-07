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
	var _prevPanPoint: CGPoint
	var _isPanning: Bool
	var _lastOrigin: CGPoint
	var _isSelected: Bool
	
	init(frame frameRect: NSRect, canvas: Canvas) {
		self._canvas = canvas
		self._prevPanPoint = CGPoint.zero
		self._isPanning = false
		self._lastOrigin = CGPoint.zero
		self._isSelected = false
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasWidget::init(coder) not implemented.")
	}
	
	// MARK: Functions for derived classes to override.
	func onMove() {
		print("CanvasWidget::onMove() should be overridden.")
	}
	
	// private - only use within commands
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_canvas.updateCurves()
	}
	
	override func mouseDown(with event: NSEvent) {
		_isPanning = true
		_prevPanPoint = event.locationInWindow
		
		_canvas._undoRedo.beginCompound(executeOnAdd: true)
		_lastOrigin = frame.origin
	}
	override func mouseDragged(with event: NSEvent) {
		if _isPanning {
			let dx = (event.locationInWindow.x - _prevPanPoint.x)
			let dy = (event.locationInWindow.y - _prevPanPoint.y)
			let pos = NSMakePoint(frame.origin.x + dx, frame.origin.y + dy)
			
			_canvas.moveCanvasWidget(widget: self, from: _lastOrigin, to: pos)
			_lastOrigin = pos
			_prevPanPoint = event.locationInWindow
		}
	}
	override func mouseUp(with event: NSEvent) {
		_canvas.moveCanvasWidget(widget: self, from: _lastOrigin, to: frame.origin)
		_canvas._undoRedo.endCompound()
		
		_isPanning = false
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
