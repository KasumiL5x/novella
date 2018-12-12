//
//  CanvasEventLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasEventLink: CanvasLink {
	let EventLink: NVEventLink
	
	init(canvas: Canvas, origin: CanvasObject, link: NVEventLink) {
		self.EventLink = link
		super.init(canvas: canvas, origin: origin)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
}
