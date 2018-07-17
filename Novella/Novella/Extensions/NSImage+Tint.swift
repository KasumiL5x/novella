//
//  NSImage+Tint.swift
//  Novella
//
//  Created by Daniel Green on 17/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

extension NSImage {
	func tinted(color: NSColor) -> NSImage {
		// duplicate and lock
		let image = self.copy() as! NSImage
		image.lockFocus()
		
		// actual tinting
		color.set()
		NSMakeRect(0, 0, image.size.width, image.size.height).fill(using: .sourceAtop)
		
		// unlock
		image.unlockFocus()
		image.isTemplate = false
		
		return image
	}
}
