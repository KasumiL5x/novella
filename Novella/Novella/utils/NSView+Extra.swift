//
//  NSView+Extra.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSView {
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
	
	func bringSubviewToFront(_ sub: NSView, ordering: NSWindow.OrderingMode = .above, relativeTo: NSView? = nil) {
		// must be contained
		if !subviews.contains(sub) {
			return
		}
		
		// must have at least two subviews
		if subviews.count < 2 {
			return
		}
		
		// cannot be last view already
		if subviews.last == sub {
			return
		}
		
		let lastIndex = subviews.count-1
		let subIndex = subviews.firstIndex(of: sub)!
		self.subviews.swapAt(subIndex, lastIndex)
	}
}
