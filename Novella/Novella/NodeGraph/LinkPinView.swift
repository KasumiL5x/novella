//
//  LinkPinView.swift
//  Novella
//
//  Created by Daniel Green on 09/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class LinkPinView: NSView {
	var _nvBaseLink: NVBaseLink
	var _canvas: Canvas
	
	var _pinLayer: CAShapeLayer
	var _curveLayer: CAShapeLayer
	var _curvePath: NSBezierPath
	
	var _trackingArea: NSTrackingArea?
	
	init(link: NVBaseLink, canvas: Canvas) {
		self._nvBaseLink = link
		self._canvas = canvas
		self._pinLayer = CAShapeLayer()
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_curveLayer)
		layer!.addSublayer(_pinLayer)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkPinView::init(coder) not implemented.")
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
	
	override func mouseEntered(with event: NSEvent) {
		print("enter")
	}
	override func mouseExited(with event: NSEvent) {
		print("exit")
	}
	override func mouseDown(with event: NSEvent) {
		print("clicked a pin")
	}
	override func mouseDragged(with event: NSEvent) {
		print("dragged a pin")
	}
	override func mouseUp(with event: NSEvent) {
		print("upped a pin")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// error checking (this shouldn't be in draw but for now it will do)
			// TODO: Move this to a sensible place.
			if _nvBaseLink._origin == nil {
				fatalError("Error: LinkPinView's NVBaseLink has NO origin.  This should never happen")
			}
			
			// draw pin
			_pinLayer.path = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5).cgPath
			_pinLayer.fillColor = NSColor.white.cgColor
			
			// clear points before drawing
			_curvePath.removeAllPoints()
			
			// origin and end points
			let origin = NSMakePoint(0.0, frame.height * 0.5)
			var end = CGPoint.zero
			
			// draw link curve
			if let asLink = _nvBaseLink as? NVLink {
				if let destination = _canvas.getLinkableWidgetFrom(linkable: asLink._transfer._destination) {
					// convert local from destination into local of self
					end = destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
					
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				}
				
				// TODO: Don't set path (or set to nil) if the destination isn't valid.
				_curveLayer.lineWidth = 2.0
				_curveLayer.strokeColor = NSColor.fromHex("#B3F865").cgColor
			}
			
			// draw branch curve
			if let asBranch = _nvBaseLink as? NVBranch {
				if let trueDest = _canvas.getLinkableWidgetFrom(linkable: asBranch._trueTransfer._destination) {
					// convert local from destination into local of self
					end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				}
				if let falseDest = _canvas.getLinkableWidgetFrom(linkable: asBranch._falseTransfer._destination) {
					// convert local from destination into local of self
					end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				}
				
				_curveLayer.lineWidth = 2.0
				_curveLayer.strokeColor = NSColor.fromHex("#EA772F").cgColor
			}
			
			// set up curve layer parameters for drawing
			_curveLayer.path = _curvePath.cgPath
			_curveLayer.fillColor = nil
			_curveLayer.fillRule = kCAFillRuleNonZero
			_curveLayer.lineCap = kCALineCapButt
			_curveLayer.lineDashPattern = nil
			_curveLayer.lineJoin = kCALineJoinMiter
			_curveLayer.lineWidth = 2.0
			_curveLayer.miterLimit = 10.0
			
			context.restoreGState()
		}
	}
}
