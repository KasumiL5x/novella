//
//  NSView+ViewAt.swift
//  novella
//
//  Created by Daniel Green on 25/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSView {
	// Custom local-space frame used for the hit testing in viewAt(:). Can override per object.
	func viewBounds() -> NSRect {
		return bounds
	}
	
	// Finds and returns the view that is hit, including subviews, if any, using their own special frame.
	func viewAt(_ point: CGPoint) -> NSView? {
		// check subviews first
		for sub in subviews.reversed() {
			if NSPointInRect(superview!.convert(point, to: sub), sub.viewBounds()) {
				if let result = sub.viewAt(superview!.convert(point, to: self)) { // defer to child view
					return result
				}
			}
		}
		
		// check self
		if self.tag != -1 && NSPointInRect(superview!.convert(point, to: self), viewBounds()) {
			return self
		}
		
		return nil
	}
}
