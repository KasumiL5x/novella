//
//  CanvasGroup.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasGroup: CanvasObject {
	let Group: NVGroup
	
	init(canvas: Canvas, group: NVGroup) {
		self.Group = group
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasGroup.onSubmerge), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onSubmerge() {
		_canvas.setupFor(group: self.Group)
	}
	
	// virtuals
	override func onMove() {
		_canvas.Doc.Positions[Group.UUID] = frame.origin
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			NSColor.green.setFill()
			NSColor.systemPink.setStroke()
			NSBezierPath(ovalIn: bounds).fill()
			NSBezierPath(ovalIn: bounds).stroke()
			
			context.restoreGState()
		}
	}
}
