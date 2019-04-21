//
//  CanvasSequence.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasSequence: CanvasObject {
	private let _popover: SequencePopover
	
	init(canvas: Canvas, sequence: NVSequence) {
		self._popover = SequencePopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75), linkable: sequence)
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasSequence.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasSequence.onAddLink), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasSequence.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasSequence.onDelete), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// load initial model data
		reloadData()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvSequence() -> NVSequence {
		return Linkable as! NVSequence
	}

	@objc private func onSubmerge() {
		_canvas.setupFor(sequence: nvSequence())
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(sequence: self, doc: _canvas.Doc)
	}
	
	@objc private func onAddLink() {
		_canvas.makeLink(forSequence: self)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Sequence?", info: "Are you sure you want to delete this Sequence? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(sequence: nvSequence())
		}
	}
	
	// virtuals
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#FF5E3A")
	}
	override func labelString() -> String {
		return nvSequence().Label.isEmpty ? "Unknown" : nvSequence().Label
	}
	override func iconImage() -> NSImage? {
		return NSImage(named: "NVSequence")
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(sequence: self, doc: _canvas.Doc)
	}
	override func didMove() {
		super.didMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
	override func reloadData() {
		super.reloadData()
		setParallelLayer(state: nvSequence().Parallel)
		setEntryLayer(state: nvSequence().Parent?.Entry == nvSequence())
	}
}
