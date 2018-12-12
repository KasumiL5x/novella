//
//  CanvasLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasLink: NSView {
	static let Size: CGFloat = 20.0
	static let OutlineInset: CGFloat = 3.0
	static let FillInset: CGFloat = 1.5
	
	private var _canvas: Canvas
	private(set) var Origin: CanvasObject?
	//
	private let _outlineLayer: CAShapeLayer
	private let _fillLayer: CAShapeLayer
	//
	private let _dragLayer: CAShapeLayer
	private var _isDragging: Bool
	private var _dragPosition: CGPoint
	private var _previousTarget: CanvasObject?
	private var _currentTarget: CanvasObject?
	
	init(canvas: Canvas, origin: CanvasObject) {
		self._canvas = canvas
		self.Origin = origin
		//
		self._outlineLayer = CAShapeLayer()
		self._fillLayer = CAShapeLayer()
		//
		self._dragLayer = CAShapeLayer()
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		self._previousTarget = nil
		self._currentTarget = nil
		super.init(frame: NSMakeRect(0, 0, CanvasLink.Size, CanvasLink.Size))
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// background first
		let bgLayer = CAShapeLayer()
		bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05).cgColor
		bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: 4.0, yRadius: 4.0).cgPath
		layer?.addSublayer(bgLayer)
		
		// outline
		let outlineRect = bounds.insetBy(dx: CanvasLink.OutlineInset, dy: CanvasLink.OutlineInset)
		_outlineLayer.lineWidth = 1.0
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.5).cgColor
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
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_isDragging = true
			_dragPosition = gesture.location(in: self)
			_dragLayer.strokeColor = NSColor.red.cgColor
			_dragLayer.path = nil // otherwise after removing animations the path will flicker
			_dragLayer.removeAllAnimations()
			
		case .changed:
			_dragPosition = gesture.location(in: self)
			let origin = NSMakePoint(bounds.midX, bounds.midY)
			_dragLayer.path = CurveHelper.catmullRom(points: [origin, _dragPosition], alpha: 1.0, closed: false).cgPath
			
			// update target
			_currentTarget = _canvas.objectAt(point: gesture.location(in: _canvas), ignoring: Origin)
			if _currentTarget != _previousTarget {
				onTargetChanged(prev: _previousTarget, curr: _currentTarget)
			}
			_previousTarget = _currentTarget
			
		case .cancelled, .ended:
			_isDragging = false
			// animate color to clear
			let colorAnim = CABasicAnimation(keyPath: "strokeColor")
			colorAnim.duration = 0.3
			colorAnim.toValue = CGColor.clear
			colorAnim.fillMode = .forwards
			colorAnim.isRemovedOnCompletion = false
			_dragLayer.add(colorAnim, forKey: colorAnim.keyPath)
			// animate stroke length to 0
			let strokeAnim = CABasicAnimation(keyPath: "strokeEnd")
			strokeAnim.toValue = 0.0
			strokeAnim.duration = 0.2
			strokeAnim.fillMode = .forwards
			strokeAnim.isRemovedOnCompletion = false
			_dragLayer.add(strokeAnim, forKey: strokeAnim.keyPath)
			
			onPanEnded(curr: _currentTarget)
			
		default:
			break
		}
		
		setNeedsDisplay(bounds)
	}
	
	// virtuals
	func onTargetChanged(prev: CanvasObject?, curr: CanvasObject?) {
		print("Please override me Alan.")
	}
	func onPanEnded(curr: CanvasObject?) {
		print("Please override me Alan.")
	}
}
