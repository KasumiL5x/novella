//
//  PinViewBranch.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinViewBranch: PinView {
	// MARK: - - Variables -
	fileprivate let _pinLayer: CAShapeLayer
	fileprivate var _pinPath: NSBezierPath
	fileprivate var _pinColor: NSColor
	fileprivate let _pinSaturation: CGFloat
	fileprivate let _trueCurveLayer: CAShapeLayer
	fileprivate let _trueCurvePath: NSBezierPath
	fileprivate var _trueCurveColor: NSColor
	fileprivate let _trueCurveSaturation: CGFloat
	fileprivate let _falseCurveLayer: CAShapeLayer
	fileprivate let _falseCurvePath: NSBezierPath
	fileprivate var _falseCurveColor: NSColor
	fileprivate let _falseCurveSaturation: CGFloat
	
	// MARK: - - Initialization -
	init(link: NVBranch, graphView: GraphView, owner: LinkableView) {
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		self._pinColor = NSColor.fromHex("#fae0cf")
		self._pinSaturation = self._pinColor.saturationComponent
		self._trueCurveLayer = CAShapeLayer()
		self._trueCurvePath = NSBezierPath()
		self._trueCurveColor = NSColor.fromHex("#EA772F")
		self._trueCurveSaturation = self._trueCurveColor.saturationComponent
		self._falseCurveLayer = CAShapeLayer()
		self._falseCurvePath = NSBezierPath()
		self._falseCurveColor = NSColor.fromHex("#ea482f")
		self._falseCurveSaturation = self._falseCurveColor.saturationComponent
		super.init(link: link, graphView: graphView, owner: owner)
		
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
		
		// configure false curve layer
		_falseCurveLayer.fillColor = nil
		_falseCurveLayer.fillRule = kCAFillRuleNonZero
		_falseCurveLayer.lineCap = kCALineCapRound
		_falseCurveLayer.lineDashPattern = nil
		_falseCurveLayer.lineJoin = kCALineJoinRound
		_falseCurveLayer.lineWidth = 2.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinViewBranch::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	override func onTrashed() {
		_pinColor = _pinColor.withSaturation(TrashMode ? Settings.graph.trashedSaturation : _pinSaturation)
		_trueCurveColor = _trueCurveColor.withSaturation(TrashMode ? Settings.graph.trashedSaturation : _trueCurveSaturation)
		_falseCurveColor = _falseCurveColor.withSaturation(TrashMode ? Settings.graph.trashedSaturation : _falseCurveSaturation)
	}
	// MARK: Destination
	func setTrueDestination(dest: NVLinkable?) {
		(BaseLink as! NVBranch).setTrueDestination(dest: dest)
		_graphView.updateCurves()
	}
	func getTrueDestination() -> NVLinkable? {
		return (BaseLink as! NVBranch).TrueTransfer.Destination
	}
	func setFalseDestination(dest: NVLinkable?) {
		(BaseLink as! NVBranch).setFalseDestination(dest: dest)
		_graphView.updateCurves()
	}
	func getFalseDestination() -> NVLinkable? {
		return (BaseLink as! NVBranch).FalseTransfer.Destination
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// draw pin
			_pinPath = NSBezierPath(roundedRect: bounds, xRadius: 2.5, yRadius: 2.5)
			_pinLayer.path = _pinPath.cgPath
			_pinLayer.fillColor = _pinColor.cgColor
			
			// draw curves
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			//
			_trueCurveLayer.path = nil
			if let trueDest = _graphView.getLinkableViewFrom(linkable: getTrueDestination()) {
				_trueCurvePath.removeAllPoints()
				// convert local from destination into local of self and make curve
				end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _trueCurvePath)
				_trueCurveLayer.path = _trueCurvePath.cgPath
				_trueCurveLayer.strokeColor = _trueCurveColor.cgColor
			}
			_falseCurveLayer.path = nil
			if let falseDest = _graphView.getLinkableViewFrom(linkable: getFalseDestination()) {
				_falseCurvePath.removeAllPoints()
				// convert local from destination into local of self and make curve
				end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _falseCurvePath)
				_falseCurveLayer.path = _falseCurvePath.cgPath
				_falseCurveLayer.strokeColor = _falseCurveColor.cgColor
			}
			
			context.restoreGState()
		}
	}
}
