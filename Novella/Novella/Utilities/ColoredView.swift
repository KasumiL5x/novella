//
//  ColoredView.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

@IBDesignable
class ColoredView: NSView {
	@IBInspectable var _color: NSColor = NSColor.clear
	
	override func draw(_ dirtyRect: NSRect) {
		_color.setFill()
		dirtyRect.fill()
		super.draw(dirtyRect)
	}
}
