//
//  CanvasEvent.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasEvent: CanvasObject {
	private let _popover: EventPopover
	
	init(canvas: Canvas, event: NVEvent) {
		self._popover = EventPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 15, 15), linkable: event)
		
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasEvent.onAddLink), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasEvent.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasEvent.onDelete), keyEquivalent: "")
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvEvent() -> NVEvent {
		return Linkable as! NVEvent
	}
	
	@objc private func onAddLink() {
		_canvas.makeLink(forEvent: self)
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(event: self, doc: _canvas.Doc)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Event?", info: "Are you sure you want to delete this Event? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(event: nvEvent())
		}
	}
	
	// virtuals
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(event: self, doc: _canvas.Doc)
	}
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#88D1B0")
	}
	override func labelString() -> String {
		return nvEvent().Label.isEmpty ? "Unknown" : nvEvent().Label
	}
	override func icon() -> NSImage? {
		return NSImage(named: "NVEvent")
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func reloadData() {
		super.reloadData()
		setParallelLayer(state: nvEvent().Parallel)
		setEntryLayer(state: nvEvent().Parent?.Entry == nvEvent())
	}
}
