//
//  BranchWidget.swift
//  Novella
//
//  Created by Daniel Green on 05/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class BranchWidget: CurveWidget {
	var _novellaBranch: NVBranch
	
	var _curveBezier: NSBezierPath
	var _curveShape: CAShapeLayer
	
	init(branch: NVBranch, canvas: Canvas) {
		self._novellaBranch = branch
		
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
		
		let originWidget = _canvas.getLinkableWidgetFrom(linkable: _novellaBranch._origin)
		var destWidget = _canvas.getLinkableWidgetFrom(linkable: _novellaBranch._trueTransfer._destination)
		
		if originWidget != nil {
			start = originWidget!.frame.origin
			start.x += originWidget!.frame.width * 0.5
			start.y += originWidget!.frame.height * 0.5
			
			start.x += originWidget!.frame.width * 0.5 // move to right side
		}
		if destWidget != nil {
			end = destWidget!.frame.origin
			end.x += destWidget!.frame.width * 0.5
			end.y += destWidget!.frame.height * 0.5
			
			end.x -= destWidget!.frame.width * 0.5 // move to left side
		}
		CurveHelper.smooth(start: start, end: end, path: _curveBezier)
		
		destWidget = _canvas.getLinkableWidgetFrom(linkable: _novellaBranch._falseTransfer._destination)
		if destWidget != nil {
			end = destWidget!.frame.origin
			end.x += destWidget!.frame.width * 0.5
			end.y += destWidget!.frame.height * 0.5
			
			end.x -= destWidget!.frame.width * 0.5 // move to left side
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
		_curveShape.strokeColor = NSColor.fromHex("#EA772F").cgColor
	}
}
