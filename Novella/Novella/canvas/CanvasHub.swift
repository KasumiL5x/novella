//
//  CanvasHub.swift
//  novella
//
//  Created by Daniel Green on 21/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class CanvasHub: CanvasObject {
	private let _popover: HubPopover
	
	init(canvas: Canvas, hub: NVHub) {
		self._popover = HubPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1), linkable: hub)
		
		ContextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasHub.onAddLink), keyEquivalent: "")
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasHub.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasHub.onDelete), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvHub() -> NVHub {
		return Linkable as! NVHub
	}
	
	@objc private func onAddLink() {
		_canvas.makeLink(forHub: self)
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(hub: self, doc: _canvas.Doc)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Hub?", info: "Are you sure you want to delete this Hub? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(hub: nvHub())
		}
	}
	
	// virtuals
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 64.0, 64.0)
	}
	override func shapeRoundness() -> CGFloat {
		return 1.0
	}
	override func layoutStyle() -> CanvasObject.LayoutStyle {
		return .iconOnly
	}
	override func hasParallelLayer() -> Bool {
		return false
	}
	override func hasEntryLayer() -> Bool {
		return false
	}
	override func mainColor() -> NSColor {
//		return NSColor.fromHex("#B0DB43")//#A379C9 #46B1C9
    return NSColor.fromHex("#AAFAC8")
	}
	override func labelString() -> String {
		return "Hub"
	}
	override func iconImage() -> NSImage? {
		return NSImage(named: "NVHub")
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_popover.show(forView: self, at: .maxX)
		_popover.setup(hub: self, doc: _canvas.Doc)
	}
	override func didMove() {
		super.didMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
}
