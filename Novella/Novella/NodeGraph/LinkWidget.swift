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
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
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
		
		let originWidget = _canvas.getLinkableWidgetFrom(linkable: _novellaLink._origin)
		let destWidget = _canvas.getLinkableWidgetFrom(linkable: _novellaLink._transfer._destination)
		
		if originWidget != nil {
			start = originWidget!.frame.origin
			start.x += originWidget!.frame.width * 0.5
			start.y += originWidget!.frame.height * 0.5
		}
		if destWidget != nil {
			end = destWidget!.frame.origin
			end.x += originWidget!.frame.width * 0.5
			end.y += originWidget!.frame.height * 0.5
		}
		
		CurveHelper.smooth(start: start, end: end, path: _curveBezier)
		
		// copy bezier path into shape layer's cgpath
		_curveShape.path = _curveBezier.cgPath
		_curveShape.fillColor = nil
		_curveShape.fillRule = kCAFillRuleNonZero
		_curveShape.lineCap = kCALineCapButt
		_curveShape.lineDashPattern = nil
		_curveShape.lineJoin = kCALineJoinMiter
		_curveShape.lineWidth = 2.0
		_curveShape.miterLimit = 10.0
		_curveShape.strokeColor = NSColor.fromHex("#B3F865").cgColor
	}
}
