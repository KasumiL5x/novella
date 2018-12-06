//
//  CanvasContext.swift
//  novella
//
//  Created by Daniel Green on 01/11/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasContext: CanvasNode {
	// MARK: - Variables
	let _contextPopover: ContextPopover
	
	// MARK: - Initialization
	init(canvas: Canvas, nvNode: NVContext, bench: Bench<NSView>) {
		_contextPopover = ContextPopover()
		super.init(canvas: canvas, nvNode: nvNode, bench: bench)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasContext::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	// MARK: Virtuals
	override func color() -> NSColor {
		return NSColor.fromHex("#FF5E3A")
	}
	override func reloadFromModel() {
		setNameLabel((Node as! NVContext).Name)
		setContentLabel((Node as! NVContext).Content)
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_contextPopover.show(forView: self, at: .minY)
		_contextPopover.setup(ctx: self.Node as! NVContext)
	}
}
