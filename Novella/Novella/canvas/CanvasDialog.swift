//
//  Dialog.swift
//  novella
//
//  Created by dgreen on 11/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasDialog: CanvasNode {
	// MARK: - Variables
	let _contentPopover: DialogPopover
	
	// MARK: - Initialization
	init(canvas: Canvas, nvNode: NVDialog, bench: Bench<NSView>) {
		_contentPopover = DialogPopover()
		super.init(canvas: canvas, nvNode: nvNode, bench: bench)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasDialog::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	// MARK: Virtuals
	override func color() -> NSColor {
		return NSColor.fromHex("#A8E6CF")
	}
	override func onClick(gesture: NSClickGestureRecognizer) {
		super.onClick(gesture: gesture)
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_contentPopover.show(forView: self, at: .minY)
		_contentPopover.setup(doc: TheCanvas.Doc, dlg: self.Node as! NVDialog)
	}
	override func onContextClick(gesture: NSClickGestureRecognizer) {
		super.onContextClick(gesture: gesture)
	}
	override func onPan(gesture: NSPanGestureRecognizer) {
		super.onPan(gesture: gesture)
	}
	override func redraw() {
		super.redraw()
	}
	override func reloadFromModel() {
		setNameLabel((Node as! NVDialog).Name)
		setContentLabel((Node as! NVDialog).Content)
	}
}
