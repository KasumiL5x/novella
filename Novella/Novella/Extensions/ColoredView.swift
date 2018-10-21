//
//  ColoredView.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

@IBDesignable
class ColoredView: NSView {
	@IBInspectable var color: NSColor = NSColor.clear
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		color.setFill()
		dirtyRect.fill()
	}
}
