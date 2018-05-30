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
	fileprivate let _trueCurveLayer: CAShapeLayer
	fileprivate let _trueCurvePath: NSBezierPath
	fileprivate let _falseCurveLayer: CAShapeLayer
	fileprivate let _falseCurvePath: NSBezierPath
	
	// MARK: - - Initialization -
	init(link: NVBranch, graphView: GraphView, owner: LinkableView) {
		self._pinLayer = CAShapeLayer()
		self._pinPath = NSBezierPath()
		self._trueCurveLayer = CAShapeLayer()
		self._trueCurvePath = NSBezierPath()
		self._falseCurveLayer = CAShapeLayer()
		self._falseCurvePath = NSBezierPath()
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
			_pinLayer.fillColor = TrashMode ? Settings.graph.pins.branchPinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchPinColor.cgColor
			
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
				_trueCurveLayer.strokeColor = TrashMode ? Settings.graph.pins.branchTrueCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchTrueCurveColor.cgColor
			}
			_falseCurveLayer.path = nil
			if let falseDest = _graphView.getLinkableViewFrom(linkable: getFalseDestination()) {
				_falseCurvePath.removeAllPoints()
				// convert local from destination into local of self and make curve
				end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
				CurveHelper.smooth(start: origin, end: end, path: _falseCurvePath)
				_falseCurveLayer.path = _falseCurvePath.cgPath
				_falseCurveLayer.strokeColor = TrashMode ? Settings.graph.pins.branchFalseCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchFalseCurveColor.cgColor
			}
			
			context.restoreGState()
		}
	}
}
