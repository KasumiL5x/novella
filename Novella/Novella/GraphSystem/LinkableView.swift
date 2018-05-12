//
//  LinkableView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class LinkableView: NSView {
	fileprivate var _nvLinkable: NVLinkable?
	
	init(frameRect: NSRect, nvLinkable: NVLinkable) {
		self._nvLinkable = nvLinkable
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkableView::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			let path = NSBezierPath(roundedRect: bounds, xRadius: 2.0, yRadius: 2.0)
			NSColor.red.setFill()
			path.fill()
			context.restoreGState()
		}
	}
}
