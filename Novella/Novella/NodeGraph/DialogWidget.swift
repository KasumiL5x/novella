//
//  DialogWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class DialogWidget: CanvasWidget {
	var _novellaDialog: Dialog?
	var _nameLabel: NSTextField
	
	init(node: Dialog, canvas: Canvas) {
		self._nameLabel = NSTextField()
		self._nameLabel.translatesAutoresizingMaskIntoConstraints = false
		self._nameLabel.isBezeled = false
		self._nameLabel.drawsBackground = false
		self._nameLabel.isEditable = false
		self._nameLabel.isSelectable = false
		self._nameLabel.textColor = NSColor.fromHex("#f2f2f2")
		self._nameLabel.stringValue = node.Name.isEmpty ? "unnamed" : node.Name
		
		self._novellaDialog = node

		// TODO: Don't use fixed size.
		super.init(frame: NSRect(x: node._editorPos.x, y: node._editorPos.y, width: 64.0, height: 64.0), canvas: canvas)
		
		self._nameLabel.sizeToFit()
		self._nameLabel.frame.origin = CGPoint(x: self.frame.width/2 - self._nameLabel.frame.width/2, y: self.frame.height/2)
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
		fatalError("DialogWidget::init(coder) not implemented.")
	}
	
	override func onMove() {
		_novellaDialog?._editorPos = frame.origin
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// draw background gradient
			let bgRadius = CGFloat(10.0)
			var path = NSBezierPath(roundedRect: bounds, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgStartColor = NSColor.fromHex("#434343").withAlphaComponent(1.0)
			let bgEndColor = NSColor.fromHex("#222222").withAlphaComponent(0.6)
			let bgColors = [bgStartColor.cgColor, bgEndColor.cgColor]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: bounds.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			// draw outline (inset)
			let outlineInset = CGFloat(1.0)
			let selectedRect = bounds.insetBy(dx: outlineInset, dy: outlineInset)
			path = NSBezierPath(roundedRect: selectedRect, xRadius: bgRadius, yRadius: bgRadius)
			NSColor.fromHex("#FAFAF6").withAlphaComponent(0.7).setStroke()
			context.resetClip()
			path.lineWidth = 1.5
			path.stroke()
			
			// draw selection indicator
			if _isSelected {
				let selectedInset = CGFloat(1.0)
				let insetRect = bounds.insetBy(dx: selectedInset, dy: selectedInset)
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.lineWidth = 3.0
				NSColor.green.setStroke()
				path.stroke()
			}
			
			context.restoreGState()
		}
	}
}
