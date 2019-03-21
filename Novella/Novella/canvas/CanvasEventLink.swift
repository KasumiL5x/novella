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
	
	// virtuals
	override func canlinkTo(obj: CanvasObject) -> Bool {
		return (obj is CanvasEvent) && !(obj as! CanvasEvent).Event.Parallel
	}
	
	override func connectTo(obj: CanvasObject?) {
		// revert old CanvasEvent back to normal state and remove self as delegate
		if let oldDest = EventLink.Destination, let oldObj = _canvas.canvasEventFor(nvEvent: oldDest) {
			oldObj.CurrentState = .normal
			oldObj.remove(delegate: self)
		}
		
		// update model link destination
		EventLink.Destination = (obj as? CanvasEvent)?.Event ?? nil
		
		// add self as delegate
		obj?.add(delegate: self)
	}
}

extension CanvasEventLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		updateCurveTo(obj: obj)
	}
}
