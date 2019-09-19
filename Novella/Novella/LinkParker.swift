//
//  LinkParker.swift
//  novella
//
//  Created by Daniel Green on 22/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class LinkParker: NSView {
	override var tag: Int {
		return 0
	}
	
	private var _bgLayer: CAShapeLayer = CAShapeLayer()
	private var _outlineLayer: CAShapeLayer = CAShapeLayer()
	private weak var _parkedLink: CanvasLink? = nil
	//
	private let _dragLayer: CAShapeLayer = CAShapeLayer()
	private var _isDragging: Bool = false
	private var _currentTarget: CanvasObject? = nil
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		sharedInit()
	}
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		sharedInit()
	}
	
	private func sharedInit() {
		wantsLayer = true
		layer?.masksToBounds = false
		
		_outlineLayer.path = NSBezierPath(ovalIn: bounds).cgPath
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.3).cgColor
		_outlineLayer.lineWidth = 4.0
		layer?.addSublayer(_outlineLayer)
		
		_bgLayer.path = NSBezierPath(ovalIn: bounds).cgPath
		_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
		_bgLayer.strokeColor = nil
		layer?.addSublayer(_bgLayer)
		
		_dragLayer.fillColor = nil
		_dragLayer.lineCap = .round
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineWidth = 2.0
		_dragLayer.strokeColor = CGColor.clear
		layer?.addSublayer(_dragLayer)
		
		let panGesture = NSPanGestureRecognizer(target: self, action: #selector(LinkParker.onPan))
		panGesture.buttonMask = 0x1
		addGestureRecognizer(panGesture)
		
		// listen for the canvas setup calls as we need to reset the parker when jumping between them.
    // also the canvas isn't accessible from here, hmm
    print("ISSUE: All documents will trigger this unless the `object` is set to a specific `Canvas` instance, but I do ont have one available.")
		NotificationCenter.default.addObserver(self, selector: #selector(LinkParker.onCanvasSetupForGroup), name: NSNotification.Name.nvCanvasSetupForGroup, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LinkParker.onCanvasSetupForSequence), name: NSNotification.Name.nvCanvasSetupForSequence, object: nil)
	}
	
	@objc private func onCanvasSetupForGroup(_ sender: NSNotification) {
		reset()
	}
	
	@objc private func onCanvasSetupForSequence(_ sender: NSNotification) {
		reset()
	}
	
	private func reset() {
		_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
		_outlineLayer.strokeColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.3).cgColor
		_outlineLayer.lineWidth = 4.0
		_parkedLink = nil
		_currentTarget = nil
	}
	
	func prime() {
		_bgLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.4).cgColor
		_outlineLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.2).cgColor
		_outlineLayer.lineWidth = 10.0
	}
	
	func unprime() {
		_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
		_outlineLayer.strokeColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.3).cgColor
		_outlineLayer.lineWidth = 4.0
	}
	
	func park(_ link: CanvasLink) {
		_parkedLink = link
		_bgLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.4).cgColor
		_outlineLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.2).cgColor
		_outlineLayer.lineWidth = 15.0
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			if _parkedLink != nil {
				_isDragging = true
				_dragLayer.strokeColor = NSColor.red.cgColor
				_dragLayer.path = nil
				_dragLayer.removeAllAnimations()
			}
			
		case .changed:
			let origin = NSMakePoint(bounds.midX, bounds.midY)
			_dragLayer.path = CurveHelper.catmullRom(points: [origin, gesture.location(in: self)], alpha: 1.0, closed: false).cgPath
			
			// note: this assumes nodes can only connect to those of the same type; a more complex solution is required if this changes.
			if let parkedLink = _parkedLink {
				let windowPos = gesture.location(in: nil)
				if let globalHitView = window?.contentView?.viewAt(windowPos) as? CanvasObject, globalHitView != parkedLink.Origin, parkedLink.canlinkTo(obj: globalHitView) {
					_currentTarget?.CurrentState = .normal // unprime existing
					_currentTarget = globalHitView
					_currentTarget?.CurrentState = .primed // prime new
				} else {
					_currentTarget?.CurrentState = .normal // unprime existing
					_currentTarget = nil
				}
			}
			
		case .cancelled, .ended:
			if let target = _currentTarget, let parkedLink = _parkedLink {
				_dragLayer.strokeColor = CGColor.clear
				parkedLink.setTarget(target)
				reset()
			} else {
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
			
		default:
			break
		}
	}
}
