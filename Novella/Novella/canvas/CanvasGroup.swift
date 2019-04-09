//
//  CanvasGroup.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasGroup: CanvasObject {
	let Group: NVGroup
	private let _popover: GroupPopover
	
	init(canvas: Canvas, group: NVGroup) {
		self.Group = group
		self._popover = GroupPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1))
		
		wantsLayer = true
		layer?.masksToBounds = false

		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasGroup.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasGroup.onEdit), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onSubmerge() {
		_canvas.setupFor(group: self.Group)
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(group: self, doc: _canvas.Doc)
	}
	
	// virtuals
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(group: self, doc: _canvas.Doc)
	}
	override func onMove() {
		super.onMove()
		_canvas.Doc.Positions[Group.UUID] = frame.origin
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#99b1c8")
	}
	override func labelString() -> String {
		return Group.Label.isEmpty ? "Unknown" : Group.Label
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
}
