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
	private let _parallelMenuItem: NSMenuItem
	private let _entryMenuItem: NSMenuItem
	
	init(canvas: Canvas, beat: NVBeat) {
		self.Beat = beat
		self._parallelMenuItem = NSMenuItem()
		self._entryMenuItem = NSMenuItem()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasBeat.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasBeat.onAddLink), keyEquivalent: "")
		//
		_parallelMenuItem.title = "Parallel"
		_parallelMenuItem.action = #selector(CanvasBeat.onParallel)
		ContextMenu.addItem(_parallelMenuItem)
		//
		_entryMenuItem.title = "Entry Beat"
		_entryMenuItem.action = #selector(CanvasBeat.onEntryBeat)
		ContextMenu.addItem(_entryMenuItem)
		
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
	
	@objc private func onParallel() {
		Beat.Parallel = !Beat.Parallel
	}
	
	@objc private func onEntryBeat() {
		if Beat.Parent?.Entry == Beat {
			Beat.Parent?.Entry = nil
		} else {
			Beat.Parent?.Entry = Beat
		}
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
		_parallelMenuItem.image = Beat.Parallel ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
		
		setEntryLayer(state: Beat.Parent?.Entry == Beat)
		_entryMenuItem.image = (Beat.Parent?.Entry == Beat) ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
	}
}
