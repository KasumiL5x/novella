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
	private let _parallelMenuItem: NSMenuItem
	private let _entryMenuItem: NSMenuItem
	
	init(canvas: Canvas, sequence: NVSequence) {
		self.Sequence = sequence
		self._parallelMenuItem = NSMenuItem()
		self._entryMenuItem = NSMenuItem()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasSequence.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasSequence.onAddLink), keyEquivalent: "")
		//
		_parallelMenuItem.title = "Parallel"
		_parallelMenuItem.action = #selector(CanvasSequence.onParallel)
		ContextMenu.addItem(_parallelMenuItem)
		//
		_entryMenuItem.title = "Entry Sequence"
		_entryMenuItem.action = #selector(CanvasSequence.onEntrySequence)
		ContextMenu.addItem(_entryMenuItem)
		//
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Edit Pre-Condition", action: nil, keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit Entry Function", action: nil, keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit Exit Function", action: nil, keyEquivalent: "")
		
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
	
	@objc private func onAddLink() {
		_canvas.makeSequenceLink(sequence: self)
	}
	
	@objc private func onParallel() {
		Sequence.Parallel = !Sequence.Parallel
	}
	
	@objc private func onEntrySequence() {
		if Sequence.Parent?.Entry == Sequence {
			Sequence.Parent?.Entry = nil
		} else {
			Sequence.Parent?.Entry = Sequence
		}
	}
	
	// virtuals
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
		_parallelMenuItem.image = Sequence.Parallel ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
		
		setEntryLayer(state: Sequence.Parent?.Entry == Sequence)
		_entryMenuItem.image = (Sequence.Parent?.Entry == Sequence) ? NSImage(named: NSImage.menuOnStateTemplateName) : NSImage(named: NSImage.stopProgressTemplateName)
	}
}
