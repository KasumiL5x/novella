//
//  CanvasContext.swift
//  novella
//
//  Created by Daniel Green on 01/11/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasContext: CanvasNode {
	init(canvas: Canvas, nvNode: NVContext, bench: Bench<NSView>) {
		super.init(canvas: canvas, nvNode: nvNode, bench: bench)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasContext::init(coder) not implemented.")
	}
	
	override func color() -> NSColor {
		return NSColor.fromHex("#FF5E3A")
	}
	override func reloadFromModel() {
		setNameLabel((Node as! NVContext).Name)
		setContentLabel((Node as! NVContext).Content)
	}
}
