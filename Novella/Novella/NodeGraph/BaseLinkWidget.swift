//
//  CurveWidget.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class BaseLinkWidget: NSView {
	let _canvas: Canvas
	var _nvBaseLink: NVBaseLink?
	
	init(frame frameRect: NSRect, nvBaseLink: NVBaseLink, canvas: Canvas) {
		self._canvas = canvas
		self._nvBaseLink = nvBaseLink
		
		super.init(frame: frameRect)
		
		wantsLayer = true
		layer!.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CurveWidget::init(coder) not implemented.")
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
}
