//
//  CanvasReturn.swift
//  novella
//
//  Created by Daniel Green on 24/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class CanvasReturn: CanvasObject {
	
	init(canvas: Canvas, rtrn: NVReturn) {
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1), linkable: rtrn)
		
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasReturn.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasReturn.onDelete), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func nvReturn() -> NVReturn {
		return Linkable as! NVReturn
	}
	
	@objc private func onEdit() {
		fatalError()
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Return?", info: "Are you sure you want to delete this Return? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(rtrn: nvReturn())
		}
	}
	
	// virtuals
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 48.0, 40.0)
	}
	override func shapeRoundness() -> CGFloat {
		return 0.5
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
		return NSColor.fromHex("#A379C9")
	}
	override func labelString() -> String {
		return "Return"
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		fatalError()
	}
	override func didMove() {
		super.didMove()
		_canvas.Doc.Positions[Linkable.UUID] = frame.origin
	}
}
