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
	
	private let _parallelLayer: CAShapeLayer
	private let _entryLayer: CAShapeLayer
	
	init(canvas: Canvas, beat: NVBeat) {
		self.Beat = beat
		self._parallelLayer = CAShapeLayer()
		self._entryLayer = CAShapeLayer()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasBeat.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasBeat.onAddLink), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// parallel layer
		let parallelSize: CGFloat = 15.0
		_parallelLayer.path = NSBezierPath(ovalIn: NSMakeRect(0, 0, parallelSize, parallelSize)).cgPath
		_parallelLayer.fillColor = NSColor.fromHex("#aaccFF").cgColor
		_parallelLayer.strokeColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.1).cgColor
		_parallelLayer.lineWidth = 2.0
		_parallelLayer.frame.origin = NSMakePoint(bounds.maxX - parallelSize - 3.0, 3.0)
		_parallelLayer.opacity = 0.0
		layer?.addSublayer(_parallelLayer)
		
		// entry layer
		let entrySize: CGFloat = 15.0
		_entryLayer.path = NSBezierPath(ovalIn: NSMakeRect(0, 0, entrySize, entrySize)).cgPath
		_entryLayer.fillColor = NSColor.fromHex("#ffaacc").cgColor
		_entryLayer.strokeColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.1).cgColor
		_entryLayer.lineWidth = 2.0
		_entryLayer.frame.origin = NSMakePoint(_parallelLayer.frame.minX - entrySize, 3.0)
		_entryLayer.opacity = 0.0
		layer?.addSublayer(_entryLayer)
		
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
		return NSMakeRect(0, 0, 100.0, 100.0 * 0.25)
	}
	override func reloadData() {
		super.reloadData()
		_parallelLayer.opacity = Beat.Parallel ? 1.0 : 0.0
		_entryLayer.opacity = Beat.Parent?.Entry == Beat ? 1.0 : 0.0
	}
}
