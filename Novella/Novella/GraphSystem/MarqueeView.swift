//
//  MarqueeView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class MarqueeView: NSView {
	// MARK: - - Variables -
	private var _origin: NSPoint
	private var _marquee: NSRect
	private var _inMarquee: Bool
	private var _roundness: CGFloat
	private var _width: CGFloat
	private var _dashPattern: [CGFloat]
	private var _dashPhase: CGFloat
	private var _color: NSColor
	
	// MARK: - - Initializers -
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
		fatalError("MarqueeView::init(coder) not implemented.")
	}
	
	// MARK: - - Properties -
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
	
	// MARK: - - Internal Functions -
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let path = NSBezierPath(roundedRect: _marquee, xRadius: _roundness, yRadius: _roundness)
			path.lineWidth = _width
			path.setLineDash(_dashPattern, count: _dashPattern.count, phase: _dashPhase)
			_color.setStroke()
			path.stroke()
			
			context.restoreGState()
		}
	}
}
