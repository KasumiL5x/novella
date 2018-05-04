//
//  CurveWidget.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class CurveWidget: NSView {
	let _canvas: Canvas
	
	init(frame frameRect: NSRect, canvas: Canvas) {
		self._canvas = canvas
		
		super.init(frame: frameRect)
		
		wantsLayer = true
		layer!.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CurveWidget::init(coder) not implemented.")
	}
}
