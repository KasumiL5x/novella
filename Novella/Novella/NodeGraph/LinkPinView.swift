//
//  LinkPinView.swift
//  Novella
//
//  Created by Daniel Green on 09/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class LinkPinView: NSView {
	var _nvBaseLink: NVBaseLink
	var _canvas: Canvas
	var _owner: LinkableWidget
	
	var _pinLayer: CAShapeLayer
	var _pinPath: NSBezierPath
	
	var _curveLayer: CAShapeLayer
	var _curvePath: NSBezierPath
	
	var _isDragging: Bool
	var _dragPosition: CGPoint
	var _dragLayer: CAShapeLayer
	var _dragPath: NSBezierPath
	
	var _trackingArea: NSTrackingArea?
	
	init(link: NVBaseLink, canvas: Canvas, owner: LinkableWidget) {
		self._nvBaseLink = link
		self._canvas = canvas
		self._owner = owner
		
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		self._dragLayer = CAShapeLayer()
		self._dragPath = NSBezierPath()
		
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_curveLayer)
		layer!.addSublayer(_dragLayer)
		layer!.addSublayer(_pinLayer)
		
		// configure curve layer
		_curveLayer.fillColor = nil
		_curveLayer.fillRule = kCAFillRuleNonZero
		_curveLayer.lineCap = kCALineCapRound
		_curveLayer.lineDashPattern = nil
		_curveLayer.lineJoin = kCALineJoinRound
		_curveLayer.lineWidth = 2.0
		
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
//		print("enter")
	}
	override func mouseExited(with event: NSEvent) {
//		print("exit")
	}
	override func mouseDown(with event: NSEvent) {
//		print("clicked a pin")
	}
	override func mouseDragged(with event: NSEvent) {
//		print("dragged a pin")
		_isDragging = true
		_dragPosition = self.convert(event.locationInWindow, from: nil)
		
		setNeedsDisplay(bounds)
		
		_canvas.onDragPin(pin: self, event: event)
		
		// so dragging obviously means that only this object receives mouse events, i.e. dragging over a node doesn't highlight it.
		// therefore, i'm thinking of passing this event up to the canvas saying a pin has been dragged, which will then somehow check
		// for elements underneth the mouse via hittest or call some function or whatever to determine the destination.
		// if this is a link it will replace destination (providing it's valid, and not SELF), and if a branch, it will bring up a new
		// pop up menu which i haven't made yet stating true or false result.  Still have a lot to figure out here.
		// I should remember that once the basics work, I should put everything into undoable commands, including assigning destinations.
		// I guess it would store previous destination and current destination, and then assign accordingly.
	}
	override func mouseUp(with event: NSEvent) {
//		print("upped a pin")
		_isDragging = false
		
		setNeedsDisplay(bounds)
		
		_canvas.onPinUp(pin: self, event: event)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// MARK: Pin Drawing
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5) // TODO: This could be optimized if the bounds never change.
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = NSColor.white.cgColor
			
			// MARK: Curve Drawing
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			_curveLayer.path = nil
			_curvePath.removeAllPoints()
			// draw link curve
			if let asLink = _nvBaseLink as? NVLink {
				if let destination = _canvas.getLinkableWidgetFrom(linkable: asLink.Transfer.Destination) {
					// convert local from destination into local of self and make curve
					end = destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
					_curveLayer.strokeColor = NSColor.fromHex("#B3F865").cgColor
					_curveLayer.path = _curvePath.cgPath
				}
			}
			// draw branch curve
			if let asBranch = _nvBaseLink as? NVBranch {
				var hadDest = false
				if let trueDest = _canvas.getLinkableWidgetFrom(linkable: asBranch.TrueTransfer.Destination) {
					// convert local from destination into local of self and make curve
					end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
					hadDest = true
				}
				if let falseDest = _canvas.getLinkableWidgetFrom(linkable: asBranch.FalseTransfer.Destination) {
					// convert local from destination into local of self and make curve
					end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
					CurveHelper.smooth(start: origin, end: end, path: _curvePath)
					hadDest = true
				}
				
				if hadDest {
					_curveLayer.path = _curvePath.cgPath
					_curveLayer.strokeColor = NSColor.fromHex("#EA772F").cgColor
				}
			}
			
			
			// MARK: Draw Drag Curve
			if _isDragging {
				_dragPath.removeAllPoints()
				end = _dragPosition
				CurveHelper.smooth(start: origin, end: end, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			} else {
				_dragLayer.path = nil
			}
			
			context.restoreGState()
		}
	}
}
