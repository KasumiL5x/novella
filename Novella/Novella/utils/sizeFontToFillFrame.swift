//
//  NSRect+Font.swift
//  novella
//
//  Created by Daniel Green on 23/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

func fontSizeToFit(forString: NSString, forRect: NSRect, withFont: NSFont, margins: CGPoint, minSize: Int=3, maxSize: Int = 40) -> Int {
	let targetSize: CGSize = NSMakeSize(forRect.width - margins.x, forRect.height - margins.y)
	
	var fontSize = minSize
	for i in minSize..<maxSize {
		let strSize = forString.size(withAttributes: [
			NSAttributedString.Key.font: NSFont(name: withFont.fontName, size: CGFloat(i))!
		])
		if strSize.width > targetSize.width || strSize.height > targetSize.height {
			fontSize = i-1
			break
		}
	}
	
	return fontSize
}

extension CATextLayer {
	func sizeFontToFillFrame(minSize: CGFloat=3, maxTries: Int=15) {
		var sizeNotOkay = true
		var attempt = 0
		
		while sizeNotOkay ||  attempt < maxTries {
			let expansionRect = self.frame
			let truncated = !NSEqualRects(NSRect.zero, expansionRect)
			if truncated {
				let actualFontSize = self.fontSize
				self.fontSize = actualFontSize - 1
				if actualFontSize < minSize {
					break
				}
			} else {
				sizeNotOkay = false
			}
			
			attempt += 1
		}
	}
}

extension NSTextField {
	func sizeFontToFillFrame(minSize: CGFloat=3, maxTries: Int=15) {
		var sizeNotOkay = true
		var attempt = 0
		
		while sizeNotOkay || attempt < maxTries {
			let expansionRect = self.expansionFrame(withFrame: self.frame)
			let truncated = !NSEqualRects(NSRect.zero, expansionRect)
			if truncated {
				if let actualFontSize: CGFloat = self.font?.fontDescriptor.object(forKey: NSFontDescriptor.AttributeName.size) as? CGFloat {
					self.font = NSFont.systemFont(ofSize: actualFontSize - 1)
					if actualFontSize < minSize {
						break
					}
				}
			} else {
				sizeNotOkay = false
			}
			
			attempt += 1
		}
	}
}
