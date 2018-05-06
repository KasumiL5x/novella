//
//  BackgroundGrid.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class GridView: NSView {
	// color
	var BackgroundColor: NSColor
	var LineColor: NSColor
	// opacity
	var MajorOpacity: CGFloat
	var MinorOpacity: CGFloat
	var Opacity: CGFloat
	// thickness
	var MajorThickness: CGFloat
	var MinorThickness: CGFloat
	var Thickness: CGFloat
	// divisors
	var MajorDivisor: Int
	var MinorDivisor: Int
	// depth
	var Density: CGFloat
	
	
	override init(frame frameRect: NSRect) {
		self.BackgroundColor = NSColor.fromHex("#36363d")
		self.LineColor = NSColor.fromHex("#787878")
		//
		self.MajorOpacity = CGFloat(0.5)
		self.MinorOpacity = CGFloat(0.4)
		self.Opacity = CGFloat(0.2)
		//
		self.MajorThickness = CGFloat(2.0)
		self.MinorThickness = CGFloat(1.5)
		self.Thickness = CGFloat(1.0)
		//
		self.MajorDivisor = 10
		self.MinorDivisor = 5
		//
		self.Density = CGFloat(10.0)
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GridView::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// solid fill
			BackgroundColor.setFill()
			context.fill(dirtyRect)
			
			let linePath = NSBezierPath()
			
			// horizontal lines
			for i in 1..<Int(bounds.size.height / Density) {
				if i % MajorDivisor == 0 {
					LineColor.withAlphaComponent(MajorOpacity).set()
					linePath.lineWidth = MajorThickness
				} else if i % MinorDivisor == 0 {
					LineColor.withAlphaComponent(MinorOpacity).set()
					linePath.lineWidth = MinorThickness
				} else {
					LineColor.withAlphaComponent(Opacity).set()
					linePath.lineWidth = Thickness
				}
				linePath.removeAllPoints()
				linePath.move(to: NSPoint(x: 0, y: CGFloat(i) * Density - 0.5))
				linePath.line(to: NSPoint(x: bounds.size.width, y: CGFloat(i) * Density - 0.5))
				linePath.stroke()
			}
			
			// vertical lines
			for i in 1..<Int(bounds.size.height / Density) {
				if i % MajorDivisor == 0 {
					LineColor.withAlphaComponent(MajorOpacity).set()
					linePath.lineWidth = MajorThickness
				} else if i % MinorDivisor == 0 {
					LineColor.withAlphaComponent(MinorOpacity).set()
					linePath.lineWidth = MinorThickness
				} else {
					LineColor.withAlphaComponent(Opacity).set()
					linePath.lineWidth = Thickness
				}
				linePath.removeAllPoints()
				linePath.move(to: NSPoint(x: CGFloat(i) * Density - 0.5, y: 0))
				linePath.line(to: NSPoint(x: CGFloat(i) * Density - 0.5, y: bounds.size.height))
				linePath.stroke()
			}
			
			context.restoreGState()
		}
	}
}
