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
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 64, 64))
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasGroup.onSubmerge), keyEquivalent: "")
		
		let bgOutline = CAGradientLayer(layer: layer)
		bgOutline.colors = [NSColor.fromHex("#FFFFFF").cgColor, NSColor.fromHex("#D7E1EC").cgColor]
		bgOutline.locations = [0.0, 1.0]
		bgOutline.startPoint = CGPoint.zero
		bgOutline.endPoint = NSMakePoint(0.0, 1.0)
		bgOutline.frame = bounds.insetBy(dx: -2.0, dy: -2.0)
		bgOutline.cornerRadius = max(bgOutline.frame.width, bgOutline.frame.height) * 0.5
		layer?.addSublayer(bgOutline)
		//
		let bgGradient = CAGradientLayer(layer: layer)
		bgGradient.colors = [NSColor.fromHex("#FFFFFF").cgColor, NSColor.fromHex("#D7E1EC").cgColor]
		bgGradient.locations = [0.0, 1.0]
		bgGradient.startPoint = NSMakePoint(0.0, 1.0)
		bgGradient.endPoint = CGPoint.zero
		bgGradient.frame = bounds
		bgGradient.cornerRadius = max(bgGradient.frame.width, bgGradient.frame.height) * 0.5
		layer?.addSublayer(bgGradient)
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
			
			context.restoreGState()
		}
	}
}
