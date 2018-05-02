//
//  CanvasWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class CanvasWidget: NSView {
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasWidget::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
	}
}
