//
//  CanvasEvent.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasEvent: CanvasObject {
	let Event: NVEvent
	
	init(canvas: Canvas, event: NVEvent) {
		self.Event = event
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15))
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			NSColor.green.setFill()
			NSColor.red.setStroke()
			NSBezierPath(ovalIn: bounds).fill()
			NSBezierPath(ovalIn: bounds).stroke()
			
			context.restoreGState()
		}
	}
}
