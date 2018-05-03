//
//  CanvasWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class CanvasWidget: NSView {
	var _prevPanPoint: CGPoint
	var _isPanning: Bool
	
	override init(frame frameRect: NSRect) {
		self._prevPanPoint = CGPoint.zero
		self._isPanning = false
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasWidget::init(coder) not implemented.")
	}
	
	override func mouseDown(with event: NSEvent) {
		_isPanning = true
		_prevPanPoint = event.locationInWindow
	}
	override func mouseDragged(with event: NSEvent) {
		if _isPanning {
			let dx = (event.locationInWindow.x - _prevPanPoint.x)
			let dy = (event.locationInWindow.y - _prevPanPoint.y)
			let pos = NSMakePoint(frame.origin.x + dx, frame.origin.y + dy)
			frame.origin = pos
			_prevPanPoint = event.locationInWindow
			
			print(pos)
		}
	}
	override func mouseUp(with event: NSEvent) {
		_isPanning = false
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
