//
//  Transfer.swift
//  Novella
//
//  Created by Daniel Green on 30/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class Transfer: NSView {
	// MARK: - Statics -
	static let SIZE: CGFloat = 12.0
	static let INSET: CGFloat = 2.0
	static let EXT_PATTERN: [NSNumber] = [10, 10]
	static let STROKE_SIZE: CGFloat = 1.0
	static let THICKNESS: CGFloat = 2.0
	
	// MARK: - Variables -
	private var _nvTransfer: NVTransfer
	private var _owner: Pin
	private var _pinLayer: CAShapeLayer
	private var _curveLayer: CAShapeLayer
	private var _curvePath: NSBezierPath
	//
	private var _dragLayer: CAShapeLayer
	private var _dragPath: NSBezierPath
	private var _isDragging: Bool
	private var _dragPosition: CGPoint
	//
	private let _functionPopover: FunctionPopover
	
	// MARK: - Properties -
	var IsDragging: Bool {
		get{ return _isDragging }
		set{
			_isDragging = newValue
			redraw()
		}
	}
	var DragPosition: CGPoint {
		get{ return _dragPosition }
		set{
			_dragPosition = newValue
			redraw()
		}
	}
	var Destination: NVObject? {
		get{ return _nvTransfer.Destination }
		set{
			_nvTransfer.Destination = newValue
			redraw()
		}
	}
	
	// MARK: - Initialization -
	init(transfer: NVTransfer, owner: Pin) {
		self._nvTransfer = transfer
		self._owner = owner
		self._pinLayer = CAShapeLayer()
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		//
		self._dragLayer = CAShapeLayer()
		self._dragPath = NSBezierPath()
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		//
		self._functionPopover = FunctionPopover(true)
		super.init(frame: NSMakeRect(0.0, 0.0, Transfer.SIZE, Transfer.SIZE))
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		
		// add layers
		layer!.addSublayer(_pinLayer)
		layer!.addSublayer(_curveLayer)
		layer!.addSublayer(_dragLayer)
		
		// configure stroke layer
		_pinLayer.lineWidth = Transfer.STROKE_SIZE
		
		// configure curve layer
		_curveLayer.fillColor = nil
		_curveLayer.lineCap = kCALineCapRound
		_curveLayer.lineDashPattern = nil
		_curveLayer.lineJoin = kCALineJoinRound
		_curveLayer.lineWidth = Transfer.THICKNESS
		
		// configure drag layer
		_dragLayer.fillColor = nil
		_dragLayer.lineCap = kCALineCapRound
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineJoin = kCALineJoinRound
		_dragLayer.lineWidth = Transfer.THICKNESS
		_dragLayer.strokeColor = NSColor.fromHex("#F67280").cgColor
		
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Transfer::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	func showFunctionPopover() {
		// must be shown before setup otherwise outlets aren't linked
		_functionPopover.show(forView: self, at: .maxX)
		_functionPopover.setup(function: _nvTransfer.Function)
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// main color based on what kind of node it's connected to and whether the owner is selected or not
			let normalColor: NSColor
			if let dest = _owner.Owner._graphView.getNodeFrom(object: _nvTransfer.Destination, includeParentGraphs: true) {
				normalColor = dest.flagColor()
			} else {
				normalColor = NSColor.fromHex("#535353")
			}
			let ownerSelectedColor = NSColor.fromHex("#f67280")
			let pinColor = (_owner.Owner.IsSelected || _owner.Owner.IsPrimed) ? ownerSelectedColor : normalColor
			
			
			// draw pin
			_pinLayer.path = NSBezierPath(ovalIn: bounds).cgPath
			if _nvTransfer.Destination != nil {
				_pinLayer.fillColor = _owner.BaseLink.InTrash ? Settings.graph.trashedColorDark.cgColor : pinColor.cgColor
				_pinLayer.strokeColor = nil
			} else {
				_pinLayer.fillColor = nil
				_pinLayer.strokeColor = _owner.BaseLink.InTrash ? Settings.graph.trashedColorDark.cgColor : pinColor.cgColor
			}
			
			// curve drawing
			_curveLayer.path = nil
			if let dest = _owner.Owner._graphView.getNodeFrom(object: _nvTransfer.Destination, includeParentGraphs: true) {
				// origin is the center of the pin
				let curveOrigin = NSMakePoint(bounds.midX, bounds.midY)
				// end is the left center of the dest node (i could also make this a closest point algorithm which may be interesting)
				let curveEnd = dest.convert(NSMakePoint(0.0, dest.frame.height * 0.5), to: self)
				
				// calculate the actual curve
				_curvePath.removeAllPoints()
				switch _owner.Owner._graphView.Document.CurveType {
				case .catmullRom:
					CurveHelper.catmullRom(points: [curveOrigin, curveEnd], alpha: 1.0, closed: false, path: _curvePath)
				case .square:
					CurveHelper.square(start: curveOrigin, end: curveEnd, path: _curvePath)
				case .line:
					CurveHelper.line(start: curveOrigin, end: curveEnd, path: _curvePath)
				}
				
				// set path and dash pattern
				_curveLayer.path = _curvePath.cgPath
				_curveLayer.strokeColor = _owner.BaseLink.InTrash ? Settings.graph.trashedColorDark.cgColor : pinColor.cgColor
				_curveLayer.lineDashPattern = (dest is GraphNode) ? Transfer.EXT_PATTERN : nil
			}
			
			// drag curve drawing
			if _isDragging {
				let curveOrigin = NSMakePoint(bounds.midX, bounds.midY)
				
				_dragPath.removeAllPoints()
				CurveHelper.catmullRom(points: [curveOrigin, _dragPosition], alpha: 1.0, closed: false, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			} else {
				_dragLayer.path = nil
			}
			
			context.restoreGState()
		}
	}
}
