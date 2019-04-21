//
//  CanvasGroup.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasGroup: CanvasObject {
	private let _popover: GroupPopover
	
	init(canvas: Canvas, group: NVGroup) {
		self._popover = GroupPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1), linkable: group)
		
		wantsLayer = true
		layer?.masksToBounds = false

		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasGroup.onSubmerge), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasGroup.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasGroup.onDelete), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvGroup() -> NVGroup {
		return Linkable as! NVGroup
	}
	
	@objc private func onSubmerge() {
		_canvas.setupFor(group: nvGroup())
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(group: self, doc: _canvas.Doc)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Group?", info: "Are you sure you want to delete this Group? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(group: nvGroup())
		}
	}
	
	// virtuals
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 125.0, 125.0 * 0.25)
	}
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#99b1c8")
	}
	override func labelString() -> String {
		return nvGroup().Label.isEmpty ? "Unknown" : nvGroup().Label
	}
	override func iconImage() -> NSImage? {
		return NSImage(named: "NVGroup")
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(group: self, doc: _canvas.Doc)
	}
	override func didMove() {
		super.didMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
}
