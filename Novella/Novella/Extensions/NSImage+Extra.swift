//
//  NSImage+Tinted.swift
//  novella
//
//  Created by Daniel Green on 25/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

extension NSImage {
	func tinted(color: NSColor, op: NSCompositingOperation = .sourceAtop) -> NSImage {
		// duplicate and lock
		let image = self.copy() as! NSImage
		image.lockFocus()
		
		// actual tinting
		color.set()
		NSMakeRect(0, 0, image.size.width, image.size.height).fill(using: op)
		
		// unlock
		image.unlockFocus()
		image.isTemplate = false
		
		return image
	}
	
	func mergedWith(_ other: NSImage, op: NSCompositingOperation = .sourceAtop) -> NSImage {
		let image = self.copy() as! NSImage
		image.lockFocus()
		other.draw(at: NSPoint.zero, from: NSRect.zero, operation: op, fraction: 1.0)
		image.unlockFocus()
		image.isTemplate = false
		return image
	}
	
	static func coloredRect(size: NSSize, color: NSColor) -> NSImage {
		let img = NSImage(size: size)
		img.lockFocus()
		color.set()
		NSMakeRect(0, 0, size.width, size.height).fill()
		img.unlockFocus()
		img.isTemplate = false
		return img
	}
}
