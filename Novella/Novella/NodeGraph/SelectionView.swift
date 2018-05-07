//
//  SelectionView.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class SelectionView: NSView {
	var _origin: NSPoint
	var _marquee: NSRect
	var _inMarquee: Bool
	
	override init(frame frameRect: NSRect) {
		self._origin = NSPoint.zero
		self._marquee = NSRect.zero
		self._inMarquee = false
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("SelectionView::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// NOTE: Turns out you cannot draw on top of subviews (https://stackoverflow.com/questions/5497805/how-to-draw-over-a-subview-of-nsview?rq=1)
			//       so we must use this view as a child of the parent and add it.
			if _inMarquee {
				
				let path = NSBezierPath(roundedRect: _marquee, xRadius: 1.0, yRadius: 1.0)
				path.lineWidth = 2.0
				path.setLineDash([5.0, 5.0], count: 2, phase: 0.0)
				NSColor.fromHex("#f2f2f2").set()
				path.stroke()
			}
			
			context.restoreGState()
		}
		
	}
}
