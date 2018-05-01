//
//  Canvas.swift
//  Novella
//
//  Created by Daniel Green on 01/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class Canvas: NSView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			drawGrid(context: context, dirtyRect: dirtyRect)
			context.restoreGState()
		}
	}
	
	func drawGrid(context: CGContext, dirtyRect: NSRect) {
		// solid fill
		let bgColor = NSColor.init(srgbRed: 54/255.0, green: 54/255.0, blue: 61/255.0, alpha: 1.0)
		bgColor.setFill()
		context.fill(dirtyRect)
		
		// line variables
		let lineColor = NSColor.init(srgbRed: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1.0)
		let majorOpacity = CGFloat(0.5)
		let minorOpacity = CGFloat(0.4)
		let defaultOpacity = CGFloat(0.2)
		let majorThickness = CGFloat(2.0)
		let minorThickness = CGFloat(1.5)
		let defaultThickness = CGFloat(1.0)
		let linePath = NSBezierPath()
		let majorDivisor = 10
		let minorDivisor = 5
		let depth = CGFloat(10.0)
		
		// horizontal lines
		for i in 1..<Int(bounds.size.height / depth) {
			if i % majorDivisor == 0 {
				lineColor.withAlphaComponent(majorOpacity).set()
				linePath.lineWidth = majorThickness
			} else if i % minorDivisor == 0 {
				lineColor.withAlphaComponent(minorOpacity).set()
				linePath.lineWidth = minorThickness
			} else {
				lineColor.withAlphaComponent(defaultOpacity).set()
				linePath.lineWidth = defaultThickness
			}
			linePath.removeAllPoints()
			linePath.move(to: NSPoint(x: 0, y: CGFloat(i) * depth - 0.5))
			linePath.line(to: NSPoint(x: bounds.size.width, y: CGFloat(i) * depth - 0.5))
			linePath.stroke()
		}
		
		// vertical lines
		for i in 1..<Int(bounds.size.height / depth) {
			if i % majorDivisor == 0 {
				lineColor.withAlphaComponent(majorOpacity).set()
				linePath.lineWidth = majorThickness
			} else if i % minorDivisor == 0 {
				lineColor.withAlphaComponent(minorOpacity).set()
				linePath.lineWidth = minorThickness
			} else {
				lineColor.withAlphaComponent(defaultOpacity).set()
				linePath.lineWidth = defaultThickness
			}
			linePath.removeAllPoints()
			linePath.move(to: NSPoint(x: CGFloat(i) * depth - 0.5, y: 0))
			linePath.line(to: NSPoint(x: CGFloat(i) * depth - 0.5, y: bounds.size.height))
			linePath.stroke()
		}
	}
}
