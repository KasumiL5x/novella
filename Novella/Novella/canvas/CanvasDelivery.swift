//
//  CanvasDelivery.swift
//  novella
//
//  Created by dgreen on 12/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasDelivery: CanvasNode {
	// MARK: - Variables
	let _contentPopover: DeliveryPopover
	
	// MARK: - Initialization
	init(canvas: Canvas, nvNode: NVDelivery, bench: Bench<NSView>) {
		_contentPopover = DeliveryPopover()
		super.init(canvas: canvas, nvNode: nvNode, bench: bench)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasDelivery::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	// MARK: Virtuals
	override func color() -> NSColor {
		return NSColor.fromHex("#FFA35F")
	}
	override func onClick(gesture: NSClickGestureRecognizer) {
		super.onClick(gesture: gesture)
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_contentPopover.show(forView: self, at: .minY)
		_contentPopover.setup(doc: TheCanvas.Doc, delivery: self.Node as! NVDelivery)
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
		setNameLabel((Node as! NVDelivery).Name)
		setContentLabel((Node as! NVDelivery).Content)
	}
}
