//
//  CanvasWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

// test
class MoveWidgetCommand: UndoableCommand {
	let _widget: CanvasWidget
	var _prev: CGPoint
	var _new: CGPoint
	
	init(widget: CanvasWidget, new: CGPoint) {
		self._widget = widget
		self._prev = widget.frame.origin
		self._new = new
	}
	
	func execute() {
		_widget.frame.origin = _new
	}
	
	func unexecute() {
		_widget.frame.origin = _prev
	}
}

class CanvasWidget: NSView {
	let _canvas: Canvas
	var _prevPanPoint: CGPoint
	var _isPanning: Bool
	
	var _moveCommand: MoveWidgetCommand?
	
	init(frame frameRect: NSRect, canvas: Canvas) {
		self._canvas = canvas
		self._prevPanPoint = CGPoint.zero
		self._isPanning = false
		
		super.init(frame: frameRect)
		
		self._moveCommand = nil
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasWidget::init(coder) not implemented.")
	}
	
	// MARK: Functions for derived classes to override.
	func onMove() {
		print("CanvasWidget::onMove() should be overridden.")
	}
	
	override func mouseDown(with event: NSEvent) {
		_isPanning = true
		_prevPanPoint = event.locationInWindow
		
		// make new move command (stores the current origin)
		// when redone, the original reference is left foating, but on mouse up we add it to the command list anywaye
		_moveCommand = MoveWidgetCommand(widget: self, new: CGPoint.zero)
	}
	override func mouseDragged(with event: NSEvent) {
		if _isPanning {
			let dx = (event.locationInWindow.x - _prevPanPoint.x)
			let dy = (event.locationInWindow.y - _prevPanPoint.y)
			let pos = NSMakePoint(frame.origin.x + dx, frame.origin.y + dy)
			frame.origin = pos
			_prevPanPoint = event.locationInWindow
			
			onMove()
		}
	}
	override func mouseUp(with event: NSEvent) {
		// set the end to the current point and run the command
		_moveCommand!._new = frame.origin
		_canvas._commandList.execute(cmd: _moveCommand!)
		
		_isPanning = false
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
