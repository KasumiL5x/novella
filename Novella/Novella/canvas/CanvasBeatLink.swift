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
		
		if let asBeat = curr as? CanvasBeat {
			// revert old CanvasBeat to normal state and remove self as a delegate
			if let oldDest = BeatLink.Destination {
				let oldObj = _canvas.canvasBeatFor(nvBeat: oldDest)
				oldObj?.CurrentState = .normal
				oldObj?.remove(delegate: self)
			}
			
			// update model beat destination
			BeatLink.Destination = asBeat.Beat
			
			// add self as a delegate
			asBeat.add(delegate: self)
			
			// enable and calculate the new curve path
			_curvelayer.isHidden = false
			let origin = NSMakePoint(bounds.midX, bounds.midY)
			let end = curr!.convert(NSMakePoint(0.0, curr!.frame.height * 0.5), to: self)
			_curvelayer.path = CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false).cgPath
		} else {
			_curvelayer.isHidden = true
			_curvelayer.path = nil
		}
		
		setNeedsDisplay(bounds)
	}
}

extension CanvasBeatLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		if let target = _currentTarget {
			let origin = NSMakePoint(bounds.midX, bounds.midY)
			let end = target.convert(NSMakePoint(0.0, target.frame.height * 0.5), to: self)
			_curvelayer.path = CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false).cgPath
		}
	}
}
