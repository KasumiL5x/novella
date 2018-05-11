//
//  BranchPinView.swift
//  Novella
//
//  Created by Daniel Green on 11/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit
import NovellaModel

class BranchPinView: BasePinView {
	var _pinLayer: CAShapeLayer
	var _pinPath: NSBezierPath
	var _trueCurveLayer: CAShapeLayer
	var _trueCurvePath: NSBezierPath
	var _falseCurveLayer: CAShapeLayer
	var _falseCurvePath: NSBezierPath
	
	override init(link: NVBaseLink, canvas: Canvas, owner: LinkableWidget) {
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		self._trueCurveLayer = CAShapeLayer()
		self._trueCurvePath = NSBezierPath()
		self._falseCurveLayer = CAShapeLayer()
		self._falseCurvePath = NSBezierPath()
		
		super.init(link: link, canvas: canvas, owner: owner)
		
		layer!.addSublayer(_trueCurveLayer)
		layer!.addSublayer(_falseCurveLayer)
		layer!.addSublayer(_pinLayer)
		
		// configure true curve layer
		_trueCurveLayer.fillColor = nil
		_trueCurveLayer.fillRule = kCAFillRuleNonZero
		_trueCurveLayer.lineCap = kCALineCapRound
		_trueCurveLayer.lineDashPattern = nil
		_trueCurveLayer.lineJoin = kCALineJoinRound
		_trueCurveLayer.lineWidth = 2.0
		_trueCurveLayer.strokeColor = NSColor.fromHex("#EA772F").cgColor
		
		// configure false curve layer
		_falseCurveLayer.fillColor = nil
		_falseCurveLayer.fillRule = kCAFillRuleNonZero
		_falseCurveLayer.lineCap = kCALineCapRound
		_falseCurveLayer.lineDashPattern = nil
		_falseCurveLayer.lineJoin = kCALineJoinRound
		_falseCurveLayer.lineWidth = 2.0
		_falseCurveLayer.strokeColor = NSColor.fromHex("#ea482f").cgColor
		
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
		fatalError("BranchPinView::init(coder) not implemented.")
	}
	
	func setTrueDest(dest: NVLinkable?) {
		(BaseLink as! NVBranch).TrueTransfer.Destination = dest
		_canvas.updateCurves()
	}
	func setFalseDest(dest: NVLinkable?) {
		(BaseLink as! NVBranch).FalseTransfer.Destination = dest
		_canvas.updateCurves()
	}
	func getTrueDest() -> NVLinkable? {
		return (BaseLink as! NVBranch).TrueTransfer.Destination
	}
	func getFalseDest() -> NVLinkable? {
		return (BaseLink as! NVBranch).FalseTransfer.Destination
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// draw pin
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5) // TODO: This could be optimized if the bounds never change.
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = NSColor.fromHex("#fae0cf").cgColor
			
			// draw curves
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			
			_trueCurveLayer.path = nil
			if let trueDest = _canvas.getLinkableWidgetFrom(linkable: getTrueDest()) {
				_trueCurvePath.removeAllPoints()
				// convert local from destination into local of self and make curve
				end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _trueCurvePath)
				_trueCurveLayer.path = _trueCurvePath.cgPath
			}
			_falseCurveLayer.path = nil
			if let falseDest = _canvas.getLinkableWidgetFrom(linkable: getFalseDest()) {
				_falseCurvePath.removeAllPoints()
				// convert local from destination into local of self and make curve
				end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _falseCurvePath)
				_falseCurveLayer.path = _falseCurvePath.cgPath
			}
			
			// tweak curve layer visuals based on whether dragging or not
			if IsDragging {
				_trueCurveLayer.lineWidth = 2.0
				_trueCurveLayer.lineDashPattern = [7, 7]
				_falseCurveLayer.lineWidth = 2.0
				_falseCurveLayer.lineDashPattern = [7, 7]
			} else {
				_trueCurveLayer.lineWidth = 2.0
				_trueCurveLayer.lineDashPattern = nil
				_falseCurveLayer.lineWidth = 2.0
				_falseCurveLayer.lineDashPattern = nil
			}
			
			context.restoreGState()
		}
	}
}
