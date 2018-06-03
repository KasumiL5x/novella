//
//  GraphBoundsView.swift
//  Novella
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class GraphBoundsView: NSView {
	private var _boundary: CGSize
	
	init(initialBounds: CGSize) {
		self._boundary = initialBounds
		super.init(frame: NSMakeRect(0.0, 0.0, initialBounds.width, initialBounds.height))
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphBoundsView::init(coder) not implemented.")
	}
	
	var Boundary: CGSize {
		get{ return _boundary }
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let bg = NSBezierPath(roundedRect: NSMakeRect(0.0, 0.0, _boundary.width, _boundary.height), xRadius: 10.0, yRadius: 10.0)
			bg.lineWidth = 10.0
			bg.lineCapStyle = .roundLineCapStyle
			bg.lineJoinStyle = .roundLineJoinStyle
			NSColor.white.withAlphaComponent(0.2).setFill()
			NSColor.white.withAlphaComponent(0.25).setStroke()
			bg.fill()
			bg.stroke()
			
			context.restoreGState()
		}
	}
}
