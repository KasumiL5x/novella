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
	// MARK: - - Statics -
	static let PIN_SIZE: CGFloat = 15.0
	static let PIN_INSET: CGFloat = 2.0
	static let PIN_SPACING: CGFloat = 2.0
	static let EXT_CURVE_PATTERN: [NSNumber] = [10, 10]
	
	// MARK: - - Variables -
	private var _nvBaseLink: NVBaseLink
	var _graphView: GraphView
	private var _owner: Node
	//
	private var _panGesture: NSPanGestureRecognizer?
	private var _isDragging: Bool
	private var _dragPosition: CGPoint
	private var _dragLayer: CAShapeLayer
	private var _dragPath: NSBezierPath
	private var _panTarget: Node?
	//
	private var _contextGesture: NSClickGestureRecognizer?
	//
	private var _trashMode: Bool
	
	// MARK: - - Initialization -
	init(link: NVBaseLink, graphView: GraphView, owner: Node) {
		self._nvBaseLink = link
		self._graphView = graphView
		self._owner = owner
		//
		self._panGesture = nil
		self._isDragging = false
		self._dragPosition = CGPoint.zero
		self._dragLayer = CAShapeLayer()
		self._dragPath = NSBezierPath()
		self._panTarget = nil
		//
		self._contextGesture = nil
		//
		self._trashMode = false
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		// force child to set bounds to size accordingly
		self.frame.size = getFrameSize()
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		
		// pan recognizer
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(PinView.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
		
		// context click recognizer
		_contextGesture = NSClickGestureRecognizer(target: self, action: #selector(PinView.onContext))
		_contextGesture!.buttonMask = 0x2 // "secondary click"
		_contextGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_contextGesture!)
		
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
	var Owner: Node {
		get{ return _owner }
	}
	var IsDragging: Bool {
		get{ return _isDragging }
		set{ _isDragging = newValue }
	}
	var DragPosition: CGPoint {
		get{ return _dragPosition }
		set{ _dragPosition = newValue }
	}
	var TrashMode: Bool {
		get{ return _trashMode }
		set{
			_trashMode = newValue
			onTrashed()
			redraw()
		}
	}
	
	// MARK: - - Functions -
	func redraw() {
		setNeedsDisplay(bounds)
	}
	func onTrashed() {
		print("PinView::onTrashed() should be overridden.")
	}
	func getFrameSize() -> NSSize {
		print("PinView::setBounds() should be overridden.")
		return NSSize.zero
	}
	func getDragOrigin() -> CGPoint {
		print("PinView::getDragOrigin() should be overridden.")
		return CGPoint.zero
	}
	func onPanStarted(_ gesture: NSPanGestureRecognizer) {
		print("PinView::onPanStarted() should be overridden.")
	}
	func onPanFinished(_ target: Node?) {
		print("PinView::onPanFinished() should be overridden.")
	}
	func onContextInternal(_ gesture: NSClickGestureRecognizer) {
		print("PinView::onContextInternal() should be overridden.")
	}
	@objc func onContextDelete() {
		BaseLink.InTrash ? BaseLink.untrash() : BaseLink.trash()
	}
	
	// MARK: Gesture Callbacks
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		if _trashMode { return }
		
		switch gesture.state {
		case .began:
			IsDragging = true
			DragPosition = gesture.location(in: self)
			redraw()
			onPanStarted(gesture)
			
		case .changed:
			DragPosition = gesture.location(in: self)
			redraw()
			
			// what is under the cursor in the graph?
			if let target = _graphView.nodeAtPoint(gesture.location(in: _graphView)) {
				// ignore trashed objects
				if target.Trashed {
					_panTarget?.unprime()
					_panTarget = nil
					break
				}
				// ignore parent
				if target == _owner {
					_panTarget?.unprime()
					_panTarget = nil
					break
				}
				// unprime previous target (in case moved without hitting empty space)
				_panTarget?.unprime()
				// set as new target
				_panTarget = target
				// prime selection
				_panTarget?.prime()
			} else {
				// not touching anything, so attempt to unprime last and then clear it
				_panTarget?.unprime()
				_panTarget = nil
			}
			
		case .cancelled, .ended:
			IsDragging = false
			redraw()
			
			// unprime, as we're done
			_panTarget?.unprime()
			
			onPanFinished(_panTarget)
			_panTarget = nil
			
		default:
			break
		}
	}
	
	@objc private func onContext(gesture: NSClickGestureRecognizer) {
		onContextInternal(gesture)
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			if _isDragging {
				let origin = getDragOrigin()
				_dragPath.removeAllPoints()
				let end = _dragPosition
				CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			} else {
				_dragLayer.path = nil
			}
			
			context.restoreGState()
		}
	}
}
