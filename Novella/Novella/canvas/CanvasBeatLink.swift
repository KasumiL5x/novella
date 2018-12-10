//
//  CanvasBeatLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasBeatLink: CanvasLink {
	let BeatLink: NVBeatLink
	
	init(link: NVBeatLink) {
		self.BeatLink = link
		super.init()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
}
