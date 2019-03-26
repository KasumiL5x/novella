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
	private let _parallelMenuItem: NSMenuItem
	private let _entryMenuItem: NSMenuItem
	
	init(canvas: Canvas, event: NVEvent) {
		self.Event = event
		self._parallelMenuItem = NSMenuItem()
		self._entryMenuItem = NSMenuItem()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15))
		
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasEvent.onAddLink), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		//
		_parallelMenuItem.title = "Parallel"
		_parallelMenuItem.action = #selector(CanvasEvent.onParallel)
		ContextMenu.addItem(_parallelMenuItem)
		//
		_entryMenuItem.title = "Entry Event"
		_entryMenuItem.action = #selector(CanvasEvent.onEntryEvent)
		ContextMenu.addItem(_entryMenuItem)
		//
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Edit Pre-Condition", action: nil, keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit Entry Function", action: nil, keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit Exit Function", action: nil, keyEquivalent: "")
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onAddLink() {
		_canvas.makeEventLink(event: self)
	}
	
	@objc private func onParallel() {
		Event.Parallel = !Event.Parallel
	}
	
	@objc private func onEntryEvent() {
		if Event.Parent?.Entry == Event {
			Event.Parent?.Entry = nil
		} else {
			Event.Parent?.Entry = Event
		}
	}
	
	// virtuals
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Event.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#88D1B0")
	}
	override func labelString() -> String {
		return Event.Label.isEmpty ? "Unknown" : Event.Label
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func reloadData() {
		super.reloadData()
		setParallelLayer(state: Event.Parallel)
		_parallelMenuItem.image = Event.Parallel ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
		
		setEntryLayer(state: Event.Parent?.Entry == Event)
		_entryMenuItem.image = (Event.Parent?.Entry == Event) ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
	}
}
