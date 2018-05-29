//
//  NSColor+Saturation.swift
//  Novella
//
//  Created by Daniel Green on 29/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

extension NSColor {
	func withSaturation(_ saturation: CGFloat) -> NSColor {
		var h: CGFloat = 0.0
		var s: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0
		
		getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		
		return NSColor(hue: h, saturation: saturation, brightness: b, alpha: a)
	}
}
