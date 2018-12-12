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
	
	init(canvas: Canvas, origin: CanvasObject, link: NVBeatLink) {
		self.BeatLink = link
		super.init(canvas: canvas, origin: origin)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	// virtuals
	override func onTargetChanged(prev: CanvasObject?, curr: CanvasObject?) {
		// revert previous object state if it exists
		prev?.CurrentState = .normal
		
		// we only care about CanvasBeat objects at this point
		if !(curr is CanvasBeat) {
			return
		}
		curr?.CurrentState = .primed
	}
	
	override func onPanEnded(curr: CanvasObject?) {
		// revert back to normal
		curr?.CurrentState = .normal
		
		if curr is CanvasBeat {
			print("TODO: Connect to Beat.")
		}
	}
}
