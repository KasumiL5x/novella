//
//  RoundedTextFieldCell.swift
//  Novella
//
//  Created by Daniel Green on 03/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

@IBDesignable
class RoundedTextFieldCell: NSTextFieldCell {
	@IBInspectable var _radius: CGFloat = 6.0
	
	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		let betterBounds = NSBezierPath(roundedRect: cellFrame, xRadius: _radius, yRadius: _radius)
		betterBounds.addClip()
		super.draw(withFrame: cellFrame, in: controlView)
		if self.isBezeled {
			betterBounds.lineWidth = 2.0
			NSColor(calibratedRed: 0.51, green: 0.643, blue: 0.804, alpha: 1.0).setStroke()
			betterBounds.stroke()
		}
	}
}
