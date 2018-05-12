//
//  PinView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinView: NSView {
	// MARK: - - Variables -
	fileprivate var _nvBaseLink: NVBaseLink
	var _graphView: GraphView
	fileprivate var _owner: LinkableView
	//
	fileprivate var _panGesture: NSPanGestureRecognizer?
	fileprivate var _isDragging: Bool
	fileprivate var _dragPosition: CGPoint
	fileprivate var _dragLayer: CAShapeLayer
	fileprivate var _dragPath: NSBezierPath
	
	// MARK: - - Initialization -
	init(link: NVBaseLink, graphView: GraphView, owner: LinkableView) {
		self._nvBaseLink = link
		self._graphView = graphView
		self._owner = owner
		//
		self._panGesture = nil
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		self._dragLayer = CAShapeLayer()
		self._dragPath = NSBezierPath()
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		
		// pan regoznizer
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(PinView.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
		
		// configure drag layer
		_dragLayer.fillColor = nil
		_dragLayer.fillRule = kCAFillRuleNonZero
		_dragLayer.lineCap = kCALineCapRound
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineJoin = kCALineJoinRound
		_dragLayer.lineWidth = 2.0
		_dragLayer.strokeColor = NSColor.red.cgColor
		layer!.addSublayer(_dragLayer)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinView::init(coder) not implemented.")
	}
	
	// MARK: - - Properties -
	var BaseLink: NVBaseLink {
		get{ return _nvBaseLink }
	}
	var IsDragging: Bool {
		get{ return _isDragging }
		set{ _isDragging = newValue }
	}
	var DragPosition: CGPoint {
		get{ return _dragPosition }
		set{ _dragPosition = newValue }
	}
	
	// MARK: - - Functions -
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	// MARK: Gesture Callbacks
	@objc fileprivate func onPan(gesture: NSPanGestureRecognizer) {
		_graphView.onPanPin(pin: self, gesture: gesture)
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			if _isDragging {
				let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
				_dragPath.removeAllPoints()
				let end = _dragPosition
				CurveHelper.smooth(start: origin, end: end, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			} else {
				_dragLayer.path = nil
			}
			
			context.restoreGState()
		}
	}
}
