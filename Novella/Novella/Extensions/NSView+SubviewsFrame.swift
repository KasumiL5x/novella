//
//  NSView+SubviewsFrame.swift
//  novella
//
//  Created by Daniel Green on 14/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSView {
	@discardableResult
	func expandToContainSubviews() -> NSSize {
		// frame is relative to the parent so we can't mix self.frame and sub.frame as their
		// coordinate systems don't match.
		
		// calculate frame relative to this view (i.e. left and below will be negative coordinates)
		var minX: CGFloat = CGFloat.infinity
		var maxX: CGFloat = -CGFloat.infinity
		var minY: CGFloat = CGFloat.infinity
		var maxY: CGFloat = -CGFloat.infinity
		for sub in subviews {
			minX = min(minX, sub.frame.minX)
			maxX = max(maxX, sub.frame.maxX)
			minY = min(minY, sub.frame.minY)
			maxY = max(maxY, sub.frame.maxY)
		}
		
		// if the min coords are negative, shift the frame back by those coordinates
		// and then zero them to account for the change
		if minX < 0.0 {
			frame.origin.x += minX // has to be plus because minX is negative
			maxX += abs(minX)
			minX = 0.0
		}
		if minY < 0.0 {
			frame.origin.y += minY
			maxY += abs(minY)
			minY = 0.0
		}
		
		// return for convenience
		return NSMakeSize(maxX, maxY)
	}
	
	/// Returns a size of the view's frame expanded to encompass out-of-bounds subviews.
	/// Probably fails if you put subviews at negative coordinates.
	func subviewsSize(expandFrame: Bool=true) -> NSSize {
		var w: CGFloat = expandFrame ? frame.width : 0.0
		var h: CGFloat = expandFrame ? frame.height : 0.0
		for sub in subviews {
			let sw = sub.frame.origin.x + sub.frame.width
			let sh = sub.frame.origin.y + sub.frame.height
			
			w = max(w, sw)
			h = max(h, sh)
		}
		return NSMakeSize(w, h)
	}
}
