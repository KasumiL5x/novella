//
//  LinkWidget.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class LinkWidget: CurveWidget {
	var _novellaLink: Link
	
	var _curveBezier: NSBezierPath
	var _curveShape: CAShapeLayer
	
	init(link: Link, canvas: Canvas) {
		self._novellaLink = link
		
		self._curveBezier = NSBezierPath()
		self._curveShape = CAShapeLayer()
		
		super.init(frame: NSRect(x: 0.0, y: 0.0, width: 64.0, height: 64.0), canvas: canvas)
		
		_curveShape.path = _curveBezier.cgPath
		layer!.addSublayer(_curveShape)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkWidget::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		// configure bezier path settings
		_curveBezier.removeAllPoints()
		_curveBezier.lineWidth = 4.0
		_curveBezier.setLineDash(nil, count: 0, phase: 0.0)
		
		// draw actual line into bezier
		var start = CGPoint.zero
		var end = CGPoint.zero
		
		let originWidget = _canvas.getCanvasWidgetFrom(linkable: _novellaLink._origin)
		let destWidget = _canvas.getCanvasWidgetFrom(linkable: _novellaLink._transfer._destination)
		
		if originWidget != nil {
			start = originWidget!.frame.origin
		}
		if destWidget != nil {
			end = destWidget!.frame.origin
		}
		
		CurveHelper.line(start: start, end: end, path: _curveBezier)
		
		// copy bezier path into shape layer's cgpath
		_curveShape.path = _curveBezier.cgPath
		_curveShape.fillColor = NSColor.green.cgColor
		_curveShape.fillRule = kCAFillRuleNonZero
		_curveShape.lineCap = kCALineCapButt
		_curveShape.lineDashPattern = nil
		_curveShape.lineJoin = kCALineJoinMiter
		_curveShape.lineWidth = 4.0
		_curveShape.miterLimit = 10.0
		_curveShape.strokeColor = NSColor.green.cgColor
	}
}
