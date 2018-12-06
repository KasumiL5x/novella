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
	
	private let _doc: Document
	private let _background: CanvasBackground
	private let _marquee: CanvasMarquee
	private var _allObjects: [CanvasObject]
	
	init(doc: Document) {
		self._doc = doc
		self._allObjects = []
		let initialFrame = NSMakeRect(0, 0, Canvas.DEFAULT_SIZE, Canvas.DEFAULT_SIZE)
		self._background = CanvasBackground(frame: initialFrame)
		self._marquee = CanvasMarquee(frame: initialFrame)
		super.init(frame: initialFrame)
		
		wantsLayer = true
		
		let pan = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onPan))
		pan.buttonMask = 0x1
		addGestureRecognizer(pan)
		
		setupFor(group: doc.Story.MainGroup)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	private func setupFor(group: NVGroup) {
		subviews.removeAll()
		
		addSubview(_background)
		addSubview(_marquee)
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_marquee.Origin = gesture.location(in: self)
			_marquee.InMarquee = true
			
		case .changed:
			if _marquee.InMarquee {
				_marquee.End = gesture.location(in: self)
			}
			
		case .cancelled, .ended:
			if _marquee.InMarquee {
				_marquee.InMarquee = false
			}
			
		default:
			break
		}
	}
}
