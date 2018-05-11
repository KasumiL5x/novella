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
			
			// MARK: Pin Drawing
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5) // TODO: This could be optimized if the bounds never change.
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = NSColor.white.cgColor
			
			// MARK: Curve Drawing
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			_curveLayer.path = nil
			_curvePath.removeAllPoints()
			var hadDest = false
			if let trueDest = _canvas.getLinkableWidgetFrom(linkable: getTrueDest()) {
				// convert local from destination into local of self and make curve
				end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				hadDest = true
			}
			if let falseDest = _canvas.getLinkableWidgetFrom(linkable: getFalseDest()) {
				// convert local from destination into local of self and make curve
				end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				hadDest = true
			}
			
			if hadDest {
				_curveLayer.path = _curvePath.cgPath
				_curveLayer.strokeColor = NSColor.fromHex("#EA772F").cgColor
			}
			
			context.restoreGState()
		}
	}
}
