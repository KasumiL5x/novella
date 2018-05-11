//
//  LinkPinView.swift
//  Novella
//
//  Created by Daniel Green on 11/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit
import NovellaModel

class LinkPinView: BasePinView {
	var _pinLayer: CAShapeLayer
	var _pinPath: NSBezierPath
	var _curveLayer: CAShapeLayer
	var _curvePath: NSBezierPath
	
	override init(link: NVBaseLink, canvas: Canvas, owner: LinkableWidget) {
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		
		super.init(link: link, canvas: canvas, owner: owner)
		
		layer!.addSublayer(_curveLayer)
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
	
	func setDest(dest: NVLinkable?) {
		(BaseLink as! NVLink).Transfer.Destination = dest
		_canvas.updateCurves()
	}
	func getDest() -> NVLinkable? {
		return (BaseLink as! NVLink).Transfer.Destination
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// MARK: Pin Drawing
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5) // TODO: This could be optimized if the bounds never change.
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = NSColor.fromHex("#ebfdd6").cgColor
			
			// MARK: Curve Drawing
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			_curveLayer.path = nil
			_curvePath.removeAllPoints()
			// draw link curve
			if let destination = _canvas.getLinkableWidgetFrom(linkable: getDest()) {
				// convert local from destination into local of self and make curve
				end = destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				_curveLayer.strokeColor = NSColor.fromHex("#B3F865").cgColor
				_curveLayer.path = _curvePath.cgPath
			}
			
			context.restoreGState()
		}
	}
}
