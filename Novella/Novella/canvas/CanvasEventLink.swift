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
	
	init(link: NVEventLink) {
		self.EventLink = link
		super.init()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
}
