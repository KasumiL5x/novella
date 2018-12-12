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
	override func canlinkTo(obj: CanvasObject) -> Bool {
		return obj is CanvasBeat
	}
	
	override func connectTo(obj: CanvasObject?) {
		// revert old CanvasBeat back to normal state and remove self as delegate
		if let oldDest = BeatLink.Destination, let oldObj = _canvas.canvasBeatFor(nvBeat: oldDest) {
			oldObj.CurrentState = .normal
			oldObj.remove(delegate: self)
		}
		
		// update model link destination
		BeatLink.Destination = (obj as? CanvasBeat)?.Beat ?? nil
		
		// add self as delegate
		obj?.add(delegate: self)
	}
}

extension CanvasBeatLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		updateCurveTo(obj: obj)
	}
}
