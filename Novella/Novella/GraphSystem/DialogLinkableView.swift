//
//  DialogView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DialogLinkableView: LinkableView {
	// MARK: - - Variables -
	fileprivate let _nameLabel: NSTextField
	
	// MARK: - - Initialization -
	init(node: NVDialog, graphView: GraphView) {
		self._nameLabel = NSTextField(labelWithString: "D")
		self._nameLabel.tag = LinkableView.HIT_IGNORE_TAG
		
		let rect = NSMakeRect(node.EditorPosition.x, node.EditorPosition.y, 1.0, 1.0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		self.frame.size = widgetRect().size
		
		// set up name label
		self._nameLabel.textColor = NSColor.fromHex("#f2f2f2")
		self._nameLabel.font = NSFont.systemFont(ofSize: 42.0, weight: .ultraLight)
		self._nameLabel.sizeToFit()
		self._nameLabel.frame.origin = NSMakePoint(self.frame.width/2 - self._nameLabel.frame.width/2, self.frame.height/2 - self._nameLabel.frame.height/2)
		self.addSubview(self._nameLabel)
		
		// add shadow
		wantsLayer = true
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.black.cgColor
		self.layer?.shadowOffset = NSMakeSize(3, -1)
		self.layer?.shadowRadius = 5.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DialogLinkableView::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func widgetRect() -> NSRect {
		return NSMakeRect(0.0, 0.0, 64.0, 64.0)
	}
	override func onMove() {
		(Linkable as! NVDialog).EditorPosition = frame.origin
	}
	
	// MARK - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// create drawing rect for this object
			let dialogRect = widgetRect()
			
			// draw background gradient
			let bgRadius = Settings.graph.nodes.roundness
			var path = NSBezierPath(roundedRect: dialogRect, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgColors = [Settings.graph.nodes.dialogStartColor.cgColor, Settings.graph.nodes.endColor.cgColor]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: dialogRect.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			// draw outline (inset)
			let outlineInset = Settings.graph.nodes.outlineInset
			let selectedRect = dialogRect.insetBy(dx: outlineInset, dy: outlineInset)
			path = NSBezierPath(roundedRect: selectedRect, xRadius: bgRadius, yRadius: bgRadius)
			context.resetClip()
			path.lineWidth = Settings.graph.nodes.outlineWidth
			Settings.graph.nodes.outlineColor.setStroke()
			path.stroke()
			
			// draw primed indicator
			if IsPrimed {
				let selectedInset = Settings.graph.nodes.primedInset
				let insetRect = dialogRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = Settings.graph.nodes.primedWidth
				Settings.graph.nodes.primedColor.setStroke()
				path.stroke()
			}
			
			// draw selection indicator
			if IsSelected {
				let selectedInset = Settings.graph.nodes.selectedInset
				let insetRect = dialogRect.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = Settings.graph.nodes.selectedWidth
				Settings.graph.nodes.selectedColor.setStroke()
				path.stroke()
			}
			
			context.restoreGState()
		}
		
	}
}
