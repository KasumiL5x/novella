//
//  CanvasBeat.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasBeat: CanvasObject {
	let Beat: NVBeat
	
	init(canvas: Canvas, beat: NVBeat) {
		self.Beat = beat
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasBeat.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasBeat.onAddLink), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}

	@objc private func onSubmerge() {
		_canvas.setupFor(beat: self.Beat)
	}
	
	@objc private func onAddLink() {
		_canvas.makeBeatLink(beat: self)
	}
	
	// virtuals
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Beat.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#FF5E3A")
	}
	override func labelString() -> String {
		return Beat.Label.isEmpty ? "Unknown" : Beat.Label
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func reloadData() {
		super.reloadData()
		setParallelLayer(state: Beat.Parallel)
		setEntryLayer(state: Beat.Parent?.Entry == Beat)
	}
}
