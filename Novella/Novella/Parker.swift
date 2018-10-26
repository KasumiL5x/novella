//
//  Parker.swift
//  novella
//
//  Created by Daniel Green on 25/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class Parker: NSView {
	override var tag: Int {
		return 0
	}
	
	private var _primed: Bool = false
	private var _transfer: Transfer? = nil
	//
	let _bgLayer = CAShapeLayer()
	//
	private var _dragLayer = CAShapeLayer()
	private var _dragPath = NSBezierPath()
	private var _isDragging = false
	private var _dragPosition = CGPoint.zero
	//
	private var _targetObject: CanvasObject?

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		
		// setup background layer
		wantsLayer = true
		layer?.masksToBounds = false
		
		// configure bg layer
		layer?.addSublayer(_bgLayer)
		_bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05).cgColor
		_bgLayer.strokeColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.2).cgColor
		_bgLayer.lineWidth = 3.0
		
		// configure drag layer
		layer?.addSublayer(_dragLayer)
		_dragLayer.fillColor = nil
		_dragLayer.lineCap = .round
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineWidth = 2.0
		
		let pan = NSPanGestureRecognizer(target: self, action: #selector(Parker.onPan))
		addGestureRecognizer(pan)
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			if _transfer != nil {
				_isDragging = true
				_dragPosition = gesture.location(in: self)
			}
			
		case .changed:
			if _isDragging {
				_dragPosition = gesture.location(in: self)
				
				let windowPos = gesture.location(in: nil)
				_targetObject?.normal()
				_targetObject = window?.contentView?.viewAt(windowPos) as? CanvasObject
				_targetObject?.prime()

			}
			
		case .cancelled, .ended:
			_isDragging = false
			
			if let target = _targetObject, let xfer = _transfer {
				switch target {
				case let asNode as CanvasNode:
					xfer.TheTransfer.Destination = asNode.Node

				case let asBranch as CanvasBranch:
					xfer.TheTransfer.Destination = asBranch.Branch

				case let asSwitch as CanvasSwitch:
					xfer.TheTransfer.Destination = asSwitch.Switch

				default:
					break
				}
				
				target.IncomingTransfers.append(xfer)
				
				xfer.redraw()
				
				_targetObject = nil
				_transfer = nil
				_primed = false
			}
			
		default:
			break
		}
		
		setNeedsDisplay(bounds)
	}
	
	func prime() {
		_primed = true
		setNeedsDisplay(bounds)
	}
	func unprime() {
		_primed = false
		setNeedsDisplay(bounds)
	}
	
	func park(_ transfer: Transfer) {
		_transfer = transfer
		_primed = false
		setNeedsDisplay(bounds)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if let ctx = NSGraphicsContext.current?.cgContext {
			ctx.saveGState()
			
			if _transfer != nil {
				_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
			} else if _primed {
				_bgLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.4).cgColor
			} else {
				_bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.2).cgColor
			}
			
			_bgLayer.path = NSBezierPath(ovalIn: bounds).cgPath
			
			if _isDragging {
				let curveOrigin = NSMakePoint(bounds.midX, bounds.midY)
				_dragPath.removeAllPoints()
				CurveHelper.catmullRom(points: [curveOrigin, _dragPosition], alpha: 1.0, closed: false, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			}
			_dragLayer.strokeColor = _isDragging ? NSColor.red.cgColor : CGColor.clear
			
			ctx.restoreGState()
		}
	}
}
