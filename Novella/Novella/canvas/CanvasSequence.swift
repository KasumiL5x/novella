//
//  CanvasSequence.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasSequence: CanvasObject {
	let Sequence: NVSequence
	private let _popover: SequencePopover
	
	init(canvas: Canvas, sequence: NVSequence) {
		self.Sequence = sequence
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

	@objc private func onSubmerge() {
		_canvas.setupFor(sequence: self.Sequence)
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
			_canvas.Doc.Story.delete(sequence: self.Sequence)
		}
	}
	
	// virtuals
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(sequence: self, doc: _canvas.Doc)
	}
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Sequence.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#FF5E3A")
	}
	override func labelString() -> String {
		return Sequence.Label.isEmpty ? "Unknown" : Sequence.Label
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func reloadData() {
		super.reloadData()
		setParallelLayer(state: Sequence.Parallel)
		setEntryLayer(state: Sequence.Parent?.Entry == Sequence)
	}
}
