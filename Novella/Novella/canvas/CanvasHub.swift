//
//  CanvasHub.swift
//  novella
//
//  Created by Daniel Green on 21/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class CanvasHub: CanvasObject {
	init(canvas: Canvas, hub: NVHub) {
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1), linkable: hub)
		
		wantsLayer = true
		layer?.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvHub() -> NVHub {
		return Linkable as! NVHub
	}
	
	// virtuals
	override func shapeRoundness() -> CGFloat {
		return 1.0
	}
	override func layoutStyle() -> CanvasObject.LayoutStyle {
		return .iconOnly
	}
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#ff00ff")
	}
	override func labelString() -> String {
		return "HUB"
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 64.0, 64.0)
	}
}
