//
//  PinBoard.swift
//  Novella
//
//  Created by Daniel Green on 05/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class PinBoard: NSView {
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinBoard::init(coder) not implemented.")
	}
	
	override var tag: Int {
		return LinkableView.HIT_NIL_TAG
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		NSColor.fromHex("#1A1A1A").withAlphaComponent(0.9).setFill()
		
		let path = NSBezierPath(roundedRect: bounds, xRadius: 5.0, yRadius: 5.0)
		path.fill()
	}
}
