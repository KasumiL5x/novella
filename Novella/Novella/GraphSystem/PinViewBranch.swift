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
	private let _pinStrokeLayer: CAShapeLayer
	private let _pinFillLayerTrue: CAShapeLayer
	private let _pinFillLayerFalse: CAShapeLayer
	private let _trueCurveLayer: CAShapeLayer
	private let _trueCurvePath: NSBezierPath
	private let _falseCurveLayer: CAShapeLayer
	private let _falseCurvePath: NSBezierPath
	
	// MARK: - - Initialization -
	init(link: NVBranch, graphView: GraphView, owner: LinkableView) {
		self._pinStrokeLayer = CAShapeLayer()
		self._pinFillLayerTrue = CAShapeLayer()
		self._pinFillLayerFalse = CAShapeLayer()
		self._trueCurveLayer = CAShapeLayer()
		self._trueCurvePath = NSBezierPath()
		self._falseCurveLayer = CAShapeLayer()
		self._falseCurvePath = NSBezierPath()
		super.init(link: link, graphView: graphView, owner: owner)
		
		layer!.addSublayer(_pinStrokeLayer)
		layer!.addSublayer(_pinFillLayerTrue)
		layer!.addSublayer(_pinFillLayerFalse)
		layer!.addSublayer(_trueCurveLayer)
		layer!.addSublayer(_falseCurveLayer)
		
		// configure stroke layer
		_pinStrokeLayer.lineWidth = 1.0
		_pinStrokeLayer.fillColor = CGColor.clear
		_pinStrokeLayer.strokeColor = NSColor.red.cgColor
		
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
	override func getFrameSize() -> NSSize {
		let actualPinSize = PinView.PIN_SIZE - PinView.PIN_INSET
		return NSMakeSize(PinView.PIN_SIZE, actualPinSize*2.0 + PinView.PIN_SPACING*3.0)
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
			
			
			// draw pin stroke
			let actualPinSize = PinView.PIN_SIZE - PinView.PIN_INSET
			let strokeRect = NSMakeRect(0.0, 0.0, PinView.PIN_SIZE, actualPinSize*2.0 + PinView.PIN_SPACING*3.0)
			let strokePath = NSBezierPath(roundedRect: strokeRect, xRadius: 5.0, yRadius: 5.0)
			_pinStrokeLayer.path = strokePath.cgPath
			_pinStrokeLayer.strokeColor = NSColor.white.cgColor
			// draw true pin
			let fillPathTrue = NSBezierPath(ovalIn: NSMakeRect(PinView.PIN_INSET*0.5, PinView.PIN_SPACING, actualPinSize, actualPinSize))
			_pinFillLayerTrue.path = fillPathTrue.cgPath
			if getTrueDestination() != nil {
				_pinFillLayerTrue.fillColor = TrashMode ? Settings.graph.pins.branchTrueCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchTrueCurveColor.cgColor
				_pinFillLayerTrue.strokeColor = nil
			} else {
				_pinFillLayerTrue.fillColor = nil
				_pinFillLayerTrue.strokeColor = TrashMode ? Settings.graph.pins.branchTrueCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchTrueCurveColor.cgColor
			}
			// draw false pin
			let truePinOffset = PinView.PIN_SPACING + actualPinSize + PinView.PIN_SPACING
			let fillPathFalse = NSBezierPath(ovalIn: NSMakeRect(PinView.PIN_INSET*0.5, truePinOffset, actualPinSize, actualPinSize))
			_pinFillLayerFalse.path = fillPathFalse.cgPath
			if getFalseDestination() != nil {
				_pinFillLayerFalse.fillColor = TrashMode ? Settings.graph.pins.branchFalseCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchFalseCurveColor.cgColor
				_pinFillLayerFalse.strokeColor = nil
			} else {
				_pinFillLayerFalse.fillColor = nil
				_pinFillLayerFalse.strokeColor = TrashMode ? Settings.graph.pins.branchFalseCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.branchFalseCurveColor.cgColor
			}
			
			
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
