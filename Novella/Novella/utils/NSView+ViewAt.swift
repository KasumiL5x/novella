//
//  NSView+ViewAt.swift
//  novella
//
//  Created by Daniel Green on 22/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSView {
	struct NovellaTag: OptionSet {
		let rawValue: Int
		
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
//		static let example = NovellaTag(rawValue: 1 << 0)
	}
	
	func novellaTag() -> NovellaTag {
		return []
	}
	
	// local-space frame used for hit testing in viewAt(point) which can be overridden
	func viewBounds() -> NSRect {
		return bounds
	}
	
	func viewAt(_ point: CGPoint, ignoreTags: NSView.NovellaTag = []) -> NSView? {
		// check subviews first
		for sub in subviews.reversed() {
			if NSPointInRect(superview!.convert(point, to: sub), sub.viewBounds()) {
				if let result = sub.viewAt(superview!.convert(point, to: self)) { // defer to child view
					return result
				}
			}
		}
		
		// global ignore tag
		if self.tag == -1 {
			return nil
		}
		
		// is in the ignore tags
		if !ignoreTags.isEmpty && !self.novellaTag().isEmpty && ignoreTags.contains(self.novellaTag()) {
			return nil
		}
		
		// bounds check
		if NSPointInRect(superview!.convert(point, to: self), viewBounds()) {
			return self
		}
		
		return nil
	}
}
