//
//  CanvasMarquee.swift
//  novella
//
//  Created by dgreen on 12/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasMarquee: NSView {
	static let ROUNDNESS: CGFloat = 3.0
	static let THICKNESS: CGFloat = 2.0
	static let COLOR: NSColor = NSColor.fromHex("#D6D6D6")
	
	// MARK: - Properties
	var InMarquee: Bool = false {
		didSet {
			if !InMarquee {
				Region = NSRect.zero
			}
			setNeedsDisplay(bounds)
		}
	}
	private(set) var Region: NSRect = NSRect.zero {
		didSet {
			setNeedsDisplay(bounds)
		}
	}
	var Origin: CGPoint = CGPoint.zero {
		didSet {
			Region.origin = Origin
		}
	}
	var End: CGPoint = CGPoint.zero {
		didSet {
			Region.origin = NSMakePoint(fmin(Origin.x, End.x), fmin(Origin.y, End.y))
			Region.size = NSMakeSize(abs(End.x - Origin.x), abs(End.y - Origin.y))
		}
	}
	
	// MARK: - Initialization
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasMarquee::init(coder) not implemented.")
	}
	
	// MARK: - Disable Hit Test
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// main shape
			let path = NSBezierPath(roundedRect: Region, xRadius: CanvasMarquee.ROUNDNESS, yRadius: CanvasMarquee.ROUNDNESS)
			path.lineWidth = CanvasMarquee.THICKNESS
			
			// fill color
			NSColor(calibratedWhite: 0.8, alpha: 0.2).setFill()
			path.fill()
			
			// outline
			CanvasMarquee.COLOR.setStroke()
			path.stroke()
			
			context.restoreGState()
		}
	}
}
