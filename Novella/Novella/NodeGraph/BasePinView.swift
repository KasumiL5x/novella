//
//  LinkPinView.swift
//  Novella
//
//  Created by Daniel Green on 09/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class BasePinView: NSView {
	fileprivate var _nvBaseLink: NVBaseLink
	var _canvas: Canvas
	var _owner: LinkableWidget
	
	var _isDragging: Bool
	var _dragPosition: CGPoint
	var _dragLayer: CAShapeLayer
	var _dragPath: NSBezierPath
	
	var _trackingArea: NSTrackingArea?
	
	var BaseLink: NVBaseLink {
		get{ return _nvBaseLink }
	}
	
	init(link: NVBaseLink, canvas: Canvas, owner: LinkableWidget) {
		self._nvBaseLink = link
		self._canvas = canvas
		self._owner = owner
		
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		self._dragLayer = CAShapeLayer()
		self._dragPath = NSBezierPath()
		
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_dragLayer)
		
		// configure drag layer
		_dragLayer.fillColor = nil
		_dragLayer.fillRule = kCAFillRuleNonZero
		_dragLayer.lineCap = kCALineCapRound
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineJoin = kCALineJoinRound
		_dragLayer.lineWidth = 2.0
		_dragLayer.strokeColor = NSColor.red.cgColor
	}
	required init?(coder decoder: NSCoder) {
		fatalError("BasePinView::init(coder) not implemented.")
	}
	
	override func updateTrackingAreas() {
		if _trackingArea != nil {
			self.removeTrackingArea(_trackingArea!)
		}
		
		let options: NSTrackingArea.Options = [
			NSTrackingArea.Options.activeInKeyWindow,
			NSTrackingArea.Options.mouseEnteredAndExited
		]
		_trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(_trackingArea!)
	}
	
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	override func mouseDragged(with event: NSEvent) {
		_isDragging = true
		_dragPosition = self.convert(event.locationInWindow, from: nil)
		
		setNeedsDisplay(bounds)
		
		_canvas.onDragPin(pin: self, event: event)
	}
	override func mouseUp(with event: NSEvent) {
		_isDragging = false
		
		setNeedsDisplay(bounds)
		
		_canvas.onPinUp(pin: self, event: event)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			

			if _isDragging {
				let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
				_dragPath.removeAllPoints()
				let end = _dragPosition
				CurveHelper.smooth(start: origin, end: end, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			} else {
				_dragLayer.path = nil
			}
			
			context.restoreGState()
		}
	}
}
