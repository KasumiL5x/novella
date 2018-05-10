//
//  SelectionView.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class SelectionView: NSView {
	fileprivate var _origin: NSPoint
	fileprivate var _marquee: NSRect
	fileprivate var _inMarquee: Bool
	fileprivate var _roundness: CGFloat
	fileprivate var _width: CGFloat
	fileprivate var _dashPattern: [CGFloat]
	fileprivate var _dashPhase: CGFloat
	fileprivate var _color: NSColor
	
	override init(frame frameRect: NSRect) {
		self._origin = NSPoint.zero
		self._marquee = NSRect.zero
		self._inMarquee = false
		self._roundness = 2.0
		self._width = 2.0
		self._dashPattern = [5.0, 5.0]
		self._dashPhase = 0.0
		self._color = NSColor.fromHex("#F8F9FC")
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("SelectionView::init(coder) not implemented.")
	}
	
	// MARK: Properties
	var Origin: NSPoint {
		get{ return _origin }
		set{
			_origin = newValue
			setNeedsDisplay(bounds)
		}
	}
	
	var Marquee: NSRect {
		get{ return _marquee }
		set{
			_marquee = newValue
			setNeedsDisplay(bounds)
		}
	}
	
	var InMarquee: Bool {
		get{ return _inMarquee }
		set{ _inMarquee = newValue }
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// NOTE: Turns out you cannot draw on top of subviews (https://stackoverflow.com/questions/5497805/how-to-draw-over-a-subview-of-nsview?rq=1)
			//       so we must use this view as a child of the parent and add it.
			let path = NSBezierPath(roundedRect: _marquee, xRadius: _roundness, yRadius: _roundness)
			path.lineWidth = _width
			path.setLineDash(_dashPattern, count: _dashPattern.count, phase: _dashPhase)
			_color.setStroke()
			path.stroke()
			
			context.restoreGState()
		}
		
	}
}
