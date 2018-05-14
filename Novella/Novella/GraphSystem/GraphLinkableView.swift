//
//  GraphLinkableView.swift
//  Novella
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphLinkableView: LinkableView {
	// MARK: - - Initialization -
	init(node: NVGraph, graphView: GraphView) {
		let rect = NSMakeRect(node.EditorPosition.x, node.EditorPosition.y, 1.0, 1.0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		self.frame.size = widgetRect().size
		
		// add shadow
		wantsLayer = true
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.black.cgColor
		self.layer?.shadowOffset = NSMakeSize(3, -1)
		self.layer?.shadowRadius = 5.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphLinkableModel::init(coder) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func widgetRect() -> NSRect {
		return NSMakeRect(0.0, 0.0, 64.0, 64.0)
	}
	override func onMove() {
		(Linkable as? NVGraph)?.EditorPosition = frame.origin
	}
	
	// MARK - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// create drawing rect for this object
			let dialogRect = widgetRect()
			
			// draw background gradient
			let bgRadius = CGFloat(10.0)
			var path = NSBezierPath(roundedRect: dialogRect, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgStartColor = NSColor.fromHex("#ff00ff").withAlphaComponent(1.0)
			let bgEndColor = NSColor.fromHex("#222222").withAlphaComponent(0.6)
			let bgColors = [bgStartColor.cgColor, bgEndColor.cgColor]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: dialogRect.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			// draw outline (inset)
			let outlineInset = CGFloat(1.0)
			let selectedRect = dialogRect.insetBy(dx: outlineInset, dy: outlineInset)
			path = NSBezierPath(roundedRect: selectedRect, xRadius: bgRadius, yRadius: bgRadius)
			NSColor.fromHex("#FAFAF6").withAlphaComponent(0.7).setStroke()
			context.resetClip()
			path.lineWidth = 1.5
			path.stroke()
			
			// draw primed indicator
			if IsPrimed {
				let selectedInset = CGFloat(1.0)
				let insetRect = dialogRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = 1.0
				NSColor.fromHex("#B3F865").setStroke()
				path.stroke()
			}
			
			// draw selection indicator
			if IsSelected {
				let selectedInset = CGFloat(1.0)
				let insetRect = dialogRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = 3.0
				NSColor.green.setStroke()
				path.stroke()
			}
			
			context.restoreGState()
		}
		
	}
}
