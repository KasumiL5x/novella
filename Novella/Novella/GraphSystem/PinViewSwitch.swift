//
//  PinViewSwitch.swift
//  Novella
//
//  Created by Daniel Green on 28/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import NovellaModel

class PinViewSwitch: PinView {
	// MARK: - Variables -
	let _defaultStrokeLayer = CAShapeLayer()
	let _defaultFillLayer = CAShapeLayer()
	let _defaultCurveLayer = CAShapeLayer()
	let _defaultCurvePath = NSBezierPath()
	var _outlineRect = NSRect.zero
	
	// MARK: - Initialization -
	init(link: NVSwitch, graphView: GraphView, owner: Node) {
		super.init(link: link, graphView: graphView, owner: owner)
		
		// configure default pin
		_defaultStrokeLayer.lineWidth = 1.0
		_defaultStrokeLayer.fillColor = CGColor.clear
		_defaultStrokeLayer.strokeColor = NSColor.red.cgColor
		//
		_defaultCurveLayer.fillColor = nil
		_defaultCurveLayer.fillRule = kCAFillRuleNonZero
		_defaultCurveLayer.lineCap = kCALineCapRound
		_defaultCurveLayer.lineDashPattern = nil
		_defaultCurveLayer.lineJoin = kCALineJoinRound
		_defaultCurveLayer.lineWidth = 2.0
		//
		layer!.addSublayer(_defaultFillLayer)
		
		_outlineRect = NSMakeRect(0.0, 0.0, PinView.PIN_SIZE, PinView.PIN_SIZE)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinViewSwitch::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	override func onTrashed() {
		fatalError()
	}
	override func getFrameSize() -> NSSize {
		return NSMakeSize(PinView.PIN_SIZE, PinView.PIN_SIZE)
	}
	override func getDragOrigin() -> CGPoint {
		return NSMakePoint(frame.width * 0.5, frame.height * 0.5)
	}
	override func onPanFinished(_ target: Node?) {
		
	}
	override func onContextInternal(_ gesture: NSClickGestureRecognizer) {
		
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			context.resetClip()
			
			let color = NSColor.systemPink
			
			// pin drawing
			let strokePath = NSBezierPath(ovalIn: bounds)
			_defaultStrokeLayer.path = strokePath.cgPath
			_defaultStrokeLayer.strokeColor = color.cgColor
			
			let fillPath = NSBezierPath(ovalIn: _outlineRect.insetBy(dx: PinView.PIN_INSET, dy: PinView.PIN_INSET))
			_defaultFillLayer.path = fillPath.cgPath
			_defaultFillLayer.fillColor = color.cgColor
			
			context.restoreGState()
		}
		
	}
}
