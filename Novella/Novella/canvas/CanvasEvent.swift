//
//  CanvasEvent.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasEvent: CanvasObject {
	let Event: NVEvent
	
	init(canvas: Canvas, event: NVEvent) {
		self.Event = event
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15))
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	// virtuals
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Event.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#FF00FF") // also not implemented this class properly yet
	}
	override func labelString() -> String {
		return Event.Label.isEmpty ? "Unknown" : Event.Label
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 100.0, 100.0 * 0.25)
	}
}
