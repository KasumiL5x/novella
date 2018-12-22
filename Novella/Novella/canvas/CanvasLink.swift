//
//  CanvasLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasLink: NSView {
	static let Size: CGFloat = 15.0
	static let OutlineInset: CGFloat = 3.0
	static let FillInset: CGFloat = 1.5
	
	private(set) var _canvas: Canvas
	private(set) var Origin: CanvasObject?
	//
	private let _outlineLayer: CAShapeLayer
	private let _fillLayer: CAShapeLayer
	//
	private let _dragLayer: CAShapeLayer
	private var _isDragging: Bool
	private var _previousTarget: CanvasObject?
	private(set) var _currentTarget: CanvasObject?
	//
	var _curvelayer: CAShapeLayer // no protected in swift...
	//
	private var _lastParker: LinkParker? // for drag drop onto a LinkParker
	
	init(canvas: Canvas, origin: CanvasObject) {
		self._canvas = canvas
		self.Origin = origin
		//
		self._outlineLayer = CAShapeLayer()
		self._fillLayer = CAShapeLayer()
		//
		self._dragLayer = CAShapeLayer()
		self._isDragging = false
		self._previousTarget = nil
		self._currentTarget = nil
		//
		self._curvelayer = CAShapeLayer()
		//
		self._lastParker = nil
		super.init(frame: NSMakeRect(0, 0, CanvasLink.Size, CanvasLink.Size))
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		let backgroundColor = NSColor(named: "NVLinkBackground")!
		let outlineColor = NSColor(named: "NVLinkOutline")!
		
		// background first
		let bgLayer = CAShapeLayer()
		bgLayer.fillColor = backgroundColor.cgColor // 0.05
		bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: 4.0, yRadius: 4.0).cgPath
		layer?.addSublayer(bgLayer)
		
		// outline
		let outlineRect = bounds.insetBy(dx: CanvasLink.OutlineInset, dy: CanvasLink.OutlineInset)
		_outlineLayer.lineWidth = 1.0
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = outlineColor.cgColor // 0.5
		_outlineLayer.path = NSBezierPath(ovalIn: outlineRect).cgPath
		layer?.addSublayer(_outlineLayer)
		
		// fill
		let fillRect = outlineRect.insetBy(dx: CanvasLink.FillInset, dy: CanvasLink.FillInset)
		_fillLayer.strokeColor = nil
		_fillLayer.fillColor = CGColor.clear
		_fillLayer.path = NSBezierPath(ovalIn: fillRect).cgPath
		layer?.addSublayer(_fillLayer)
		
		// pan gesture
		let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CanvasLink.onPan))
		panGesture.buttonMask = 0x1
		addGestureRecognizer(panGesture)
		
		// drag layer
		_dragLayer.fillColor = nil
		_dragLayer.lineCap = .round
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineWidth = 2.0
		_dragLayer.strokeColor = CGColor.clear
		layer?.addSublayer(_dragLayer)
		
		// curve layer
		_curvelayer.fillColor = nil
		_curvelayer.lineCap = .round
		_curvelayer.lineWidth = 2.0
		_curvelayer.strokeColor = NSColor.black.cgColor
		layer?.addSublayer(_curvelayer)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func redraw() {
		// calculate curve as the origin will have changed
		if let target = _currentTarget {
			updateCurveTo(obj: target)
		}
		setNeedsDisplay(bounds)
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_isDragging = true
			_dragLayer.strokeColor = NSColor.red.cgColor
			_dragLayer.path = nil // otherwise after removing animations the path will flicker
			_dragLayer.removeAllAnimations()
			
		case .changed:
			let origin = NSMakePoint(bounds.midX, bounds.midY)
			_dragLayer.path = CurveHelper.catmullRom(points: [origin, gesture.location(in: self)], alpha: 1.0, closed: false).cgPath
			
			// update target (only if valid and can be connected to as defined by the derived classes)
			if let target = _canvas.objectAt(point: gesture.location(in: _canvas), ignoring: Origin), canlinkTo(obj: target) {
				_currentTarget = target
			} else {
				_currentTarget = nil
			}
			// did the target change?
			if _currentTarget != _previousTarget {
				// revert previous target's state
				_previousTarget?.CurrentState = .normal
				// prime current target
				_currentTarget?.CurrentState = .primed
			}
			// update previous target
			_previousTarget = _currentTarget
			
			// handle global out-of-canvas dragging (in this case for link parkers)
			let windowPos = gesture.location(in: nil)
			let globalHitView = window?.contentView?.viewAt(windowPos)
			_lastParker?.unprime() // previous
			_lastParker = globalHitView as? LinkParker
			_lastParker?.prime() // new one
			
			
		case .cancelled, .ended:
			_isDragging = false
			
			// let the delegate handle connection
			connectTo(obj: _currentTarget)
			
			if let target = _currentTarget {
				target.CurrentState = .normal
				updateCurveTo(obj: target)
				_dragLayer.strokeColor = CGColor.clear // don't want a nice transition otherwise there would be two curves
			} else {
				_curvelayer.strokeColor = CGColor.clear
				// animate the drag layer back to the origin
				let colorAnim = CABasicAnimation(keyPath: "strokeColor")
				colorAnim.duration = 0.3
				colorAnim.toValue = CGColor.clear
				colorAnim.fillMode = .forwards
				colorAnim.isRemovedOnCompletion = false
				_dragLayer.add(colorAnim, forKey: colorAnim.keyPath)
				let strokeAnim = CABasicAnimation(keyPath: "strokeEnd")
				strokeAnim.toValue = 0.0
				strokeAnim.duration = 0.2
				strokeAnim.fillMode = .forwards
				strokeAnim.isRemovedOnCompletion = false
				_dragLayer.add(strokeAnim, forKey: strokeAnim.keyPath)
			}
			
			// handle drop on parker if present
			if let parker = _lastParker {
				parker.park(self)
			}

		default:
			break
		}
		
		setNeedsDisplay(bounds)
	}
	
	func setTarget(_ target: CanvasObject) {
		if canlinkTo(obj: target) && target != Origin {
			_lastParker = nil
			_previousTarget = nil
			_currentTarget = target
			connectTo(obj: target)
			redraw()
		}
	}
	
	func updateCurveTo(obj: CanvasObject) {
		_curvelayer.strokeColor = obj.mainColor().cgColor
		let origin = NSMakePoint(bounds.midX, bounds.midY)
		let end = obj.convert(NSMakePoint(0.0, obj.frame.height * 0.5), to: self)
		_curvelayer.path = CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false).cgPath
	}
	
	// virtuals
	func canlinkTo(obj: CanvasObject) -> Bool {
		print("Alan, please override.")
		return false
	}
	func connectTo(obj: CanvasObject?) {
		print("Alan, please override.")
	}
}
