//
//  OutputPin.swift
//  Novella
//
//  Created by Daniel Green on 09/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class OutputPin: NSView {
	var _owner: LinkableWidget
	
	init(owner: LinkableWidget) {
		self._owner = owner
		
		super.init(frame: NSRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
	}
	required init?(coder decoder: NSCoder) {
		fatalError("OutputPin::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let path = NSBezierPath(roundedRect: bounds, xRadius: 5.0, yRadius: 5.0)
			NSColor.white.setFill()
			path.fill()
			
			context.restoreGState()
		}
		
	}
}
