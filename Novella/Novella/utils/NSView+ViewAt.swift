//
//  NSView+ViewAt.swift
//  novella
//
//  Created by Daniel Green on 22/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

struct NovellaTag: OptionSet {
	let rawValue: Int
	
	init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	static let canvasGroup = NovellaTag(rawValue: 1 << 0)
	static let canvasSequence = NovellaTag(rawValue: 1 << 1)
	static let canvasEvent = NovellaTag(rawValue: 1 << 2)
	static let all = NovellaTag(rawValue: ~0)
}

protocol NovellaTaggable {
	var novellaTag: NovellaTag {get}
}

extension NSView {
	// local-space frame used for hit testing in viewAt(point) which can be overridden
	func viewBounds() -> NSRect {
		return bounds
	}
	
	func viewAt(_ point: CGPoint, byType: NovellaTag) -> NovellaTaggable? {
		// check subviews first
		for sub in subviews.reversed() {
			if NSPointInRect(superview!.convert(point, to: sub), sub.viewBounds()) {
				if let result = sub.viewAt(superview!.convert(point, to: self), byType: byType) { // defer to child view
					return result
				}
			}
		}
		
		if let asTaggable = self as? NovellaTaggable {
			// tag check
			if asTaggable.novellaTag.isEmpty || !byType.contains(asTaggable.novellaTag) {
				return nil
			}
			
			// bounds check
			if NSPointInRect(superview!.convert(point, to: self), viewBounds()) {
				return self as? NovellaTaggable
			}
		}
		return nil
	}
	
	func viewAt(_ point: CGPoint, byIgnoringTags: [Int] = []) -> NSView? {
		// check subviews first
		for sub in subviews.reversed() {
			if NSPointInRect(superview!.convert(point, to: sub), sub.viewBounds()) {
				if let result = sub.viewAt(superview!.convert(point, to: self), byIgnoringTags: byIgnoringTags) { // defer to child view
					return result
				}
			}
		}
		
		// global ignore tag
		if self.tag == -1 {
			return nil
		}
		
		// is in ignore tags
		if byIgnoringTags.contains(self.tag) {
			return nil
		}
		
		// bounds check
		if NSPointInRect(superview!.convert(point, to: self), viewBounds()) {
			return self
		}
		
		return nil
	}
}
