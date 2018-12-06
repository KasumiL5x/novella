//
//  Canvas.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class Canvas: NSView {
	static let DEFAULT_SIZE: CGFloat = 600000.0
	
	private let _background: CanvasBackground
	
	init() {
		let initialFrame = NSMakeRect(0, 0, Canvas.DEFAULT_SIZE, Canvas.DEFAULT_SIZE)
		self._background = CanvasBackground(frame: initialFrame)
		super.init(frame: initialFrame)
		
		wantsLayer = true
		
		addSubview(_background)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
}
