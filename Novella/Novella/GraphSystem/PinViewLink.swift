//
//  PinViewLink.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinViewLink: PinView {
	// MARK: - - Variables -
	fileprivate let _pinLayer: CAShapeLayer
	fileprivate var _pinPath: NSBezierPath
	fileprivate var _pinColor: NSColor
	fileprivate let _curveLayer: CAShapeLayer
	fileprivate let _curvePath: NSBezierPath
	fileprivate var _curveColor: NSColor
	
	// MARK: - - Initialization -
	init(link: NVLink, graphView: GraphView, owner: LinkableView) {
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		self._pinColor = NSColor.fromHex("#ebfdd6")
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		self._curveColor = NSColor.fromHex("#B3F865")
		super.init(link: link, graphView: graphView, owner: owner)
		
		// add layers
		layer!.addSublayer(_curveLayer)
		layer!.addSublayer(_pinLayer)
		
		// configure curve layer
		_curveLayer.fillColor = nil
		_curveLayer.fillRule = kCAFillRuleNonZero
		_curveLayer.lineCap = kCALineCapRound
		_curveLayer.lineDashPattern = nil
		_curveLayer.lineJoin = kCALineJoinRound
		_curveLayer.lineWidth = 2.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinViewLink::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	override func onTrashed() {
		_pinColor = TrashMode ? _pinColor.withSaturation(Settings.graph.trashedSaturation) : _pinColor
		_curveColor = TrashMode ? _curveColor.withSaturation(Settings.graph.trashedSaturation) : _curveColor
	}
	// MARK: Destination
	func setDestination(dest: NVLinkable?) {
		(BaseLink as! NVLink).setDestination(dest: dest)
		_graphView.updateCurves()
	}
	func getDestination() -> NVLinkable? {
		return (BaseLink as! NVLink).Transfer.Destination
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// MARK: Pin Drawing
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5)
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = _pinColor.cgColor
			
			// MARK: Curve Drawing
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			_curveLayer.path = nil
			_curvePath.removeAllPoints()
			// draw link curve
			if let destination = _graphView.getLinkableViewFrom(linkable: getDestination()) {
				// convert local from destination into local of self and make curve
				end = destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _curvePath)
				_curveLayer.strokeColor = _curveColor.cgColor
				_curveLayer.path = _curvePath.cgPath
			}
			
			context.restoreGState()
		}
	}
}
