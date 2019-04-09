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
	private let _popover: EventPopover
	
	init(canvas: Canvas, event: NVEvent) {
		self.Event = event
		self._popover = EventPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15))
		
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasEvent.onAddLink), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasEvent.onEdit), keyEquivalent: "")
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onAddLink() {
		_canvas.makeEventLink(event: self)
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(event: self, doc: _canvas.Doc)
	}
	
	// virtuals
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(event: self, doc: _canvas.Doc)
	}
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
		setEntryLayer(state: Event.Parent?.Entry == Event)
	}
}
