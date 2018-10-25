//
//  Transfer.swift
//  novella
//
//  Created by dgreen on 13/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class Transfer: NSView {
	static let OUTLINE_SIZE: CGFloat = 1.0
	static let FILL_INSET: CGFloat = 0.25 // as a percentage of size
	
	// MARK: - Variables
	private var _canvas: Canvas
	//
	private var _size: CGFloat
	private var _outlineLayer = CAShapeLayer()
	private var _fillLayer = CAShapeLayer()
	//
	private var _panGesture: NSPanGestureRecognizer? = nil
	private var _dragLayer = CAShapeLayer()
	private var _dragPath = NSBezierPath()
	private var isDragging = false
	private var _dragPosition = CGPoint.zero
	//
	private var _contextGesture: NSClickGestureRecognizer? = nil
	//
	private var _curveLayer = CAShapeLayer()
	private var _curvePath = NSBezierPath()
	//
	private var _focusedCurveColor = NSColor.fromHex("#f67280").cgColor
	private var _focusedDashPattern: [NSNumber] = [10,7]
	private var _focusedDashDuration = CFTimeInterval(0.2)
	private var _focusedThickness: CGFloat = 3.0
	private var _regularThickness: CGFloat = 2.0
	//
	private var _functionPopover = FunctionPopover()
	//
	private var _lastParker: Parker? = nil
	
	// MARK: - Properties
	var TargetObject: CanvasObject? = nil
	var Menu: NSMenu = NSMenu()
	private(set) var TheTransfer: NVTransfer
	var OutlineColor: NSColor = NSColor.black {
		didSet {
			_outlineLayer.strokeColor = OutlineColor.cgColor
			_dragLayer.strokeColor = OutlineColor.cgColor
			redraw()
		}
	}
	var Focused: Bool = false {
		didSet {
			redraw()
		}
	}

	
	// MARK: - Initialization
	init(size: CGFloat, transfer: NVTransfer, canvas: Canvas) {
		self._size = size
		self.TheTransfer = transfer
		self._canvas = canvas
		super.init(frame: NSMakeRect(0, 0, size, size))
		
		// setup background layer
		wantsLayer = true
		layer?.masksToBounds = false
		
		// configure outline layer
		layer!.addSublayer(_outlineLayer)
		_outlineLayer.lineWidth = Transfer.OUTLINE_SIZE
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = OutlineColor.cgColor
		_outlineLayer.lineCap = .round
		
		// configure fill layer
		layer!.addSublayer(_fillLayer)
		_fillLayer.fillColor = CGColor.clear
		_fillLayer.strokeColor = nil
		
		// pan gesture
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(Transfer.onPan))
		_panGesture?.buttonMask = 0x1 // "primary click"
		addGestureRecognizer(_panGesture!)
		
		// configure drag layer
		layer!.addSublayer(_dragLayer)
		_dragLayer.fillColor = nil
		_dragLayer.lineCap = .round
		_dragLayer.lineDashPattern = [5, 5]
		_dragLayer.lineWidth = 2.0
		
		// context gesture
		_contextGesture = NSClickGestureRecognizer(target: self, action: #selector(Transfer.onContextClick))
		_contextGesture?.buttonMask = 0x2 // "secondary click"
		_contextGesture?.numberOfClicksRequired = 1
		addGestureRecognizer(_contextGesture!)
		
		// configure curve layer
		layer!.addSublayer(_curveLayer)
		_curveLayer.fillColor = nil
		_curveLayer.lineCap = .round
		_curveLayer.lineWidth = _regularThickness
		
		// base menu configuration (owners can add their own)
		Menu.addItem(withTitle: "Edit Function", action: #selector(Transfer.onMenuFunction), keyEquivalent: "")
		
		// if destination object already exists, add to IncomingTransfers
		if let nvDest = transfer.Destination, let destObject = _canvas.canvasObjectFor(nvLinkable: nvDest) {
			destObject.IncomingTransfers.append(self)
		}
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Transfer::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	// MARK: Gesture Callbacks
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			// remove any selection
			_canvas.Selection?.select([], append: false)
			
			// remove this transfer from target object's transfer if it exists
			if let idx = TargetObject?.IncomingTransfers.index(of: self) {
				TargetObject?.IncomingTransfers.remove(at: idx)
			}
			// reset transfer object and then nil it out as we started a new drag
			TargetObject?.normal()
			TargetObject = nil
			
			// remove existing destination/target
			TheTransfer.Destination = nil
			
			// kick off dragging
			isDragging = true
			_dragPosition = gesture.location(in: self)
			
		case .changed:
			_dragPosition = gesture.location(in: self)
			
			// handle un/priming of potential links
			if let target = _canvas.objectAt(point: gesture.location(in: _canvas)) {
				TargetObject?.normal()
				TargetObject = target
				TargetObject?.prime()
			} else {
				TargetObject?.normal()
				TargetObject = nil
			}
			
			// handle priming of Parkers
			//
			_lastParker?.unprime() // unprime any previous parkers
			let windowPos = gesture.location(in: nil)
			let hitView = window?.contentView?.viewAt(windowPos)
			_lastParker = hitView as? Parker
			_lastParker?.prime() // prime new parker
			
		case .cancelled, .ended:
			isDragging = false
			
			// set target accordingly
			if TargetObject == nil {
				TheTransfer.Destination = nil
			} else {
				switch TargetObject {
				case let asCanvasNode as CanvasNode:
					TheTransfer.Destination = asCanvasNode.Node
				case let asCanvasBranch as CanvasBranch:
					TheTransfer.Destination = asCanvasBranch.Branch
				case let asCanvasSwitch as CanvasSwitch:
					TheTransfer.Destination = asCanvasSwitch.Switch
				default:
					TheTransfer.Destination = nil
				}
				// add self to target object's incoming transfers so this transfer updates when it moves etc.
				TargetObject?.IncomingTransfers.append(self)
				// revert state to normal of target
				TargetObject?.normal()
			}
			
			// reset target object
			TargetObject = nil
			
			// handle parking
			if let parker = _lastParker {
				parker.park(self)
			}
			
		default:
			break
		}
		
		redraw()
	}
	@objc private func onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(Menu, with: NSApp.currentEvent!, for: self)
	}
	
	// MARK: Menu Callbacks
	@objc private func onMenuFunction() {
		_functionPopover.show(forView: self, at: .minY)
		_functionPopover.setup(transfer: TheTransfer)
	}
	
	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// is this transfer actually connected to another node?
			let destObject: CanvasObject?
			if TheTransfer.Destination != nil {
				destObject = _canvas.canvasObjectFor(nvLinkable: TheTransfer.Destination!)
			} else {
				destObject = nil
			}
			let destColor = destObject?.color().cgColor ?? NSColor.fromHex("#3c3c3c").cgColor
			
			// draw outline
			_outlineLayer.path = NSBezierPath(ovalIn: bounds).cgPath
			
			// draw fill
			_fillLayer.path = NSBezierPath(ovalIn: bounds.insetBy(dx: _size * Transfer.FILL_INSET * 0.5, dy: _size * Transfer.FILL_INSET * 0.5)).cgPath
			_fillLayer.fillColor = destObject != nil ? destColor : CGColor.clear
			
			// curve drawing
			if let destObject = destObject {
				_curvePath.removeAllPoints()
				let curveOrigin = NSMakePoint(bounds.midX, bounds.midY)
				let curveEnd = destObject.convert(NSMakePoint(0, destObject.frame.height * 0.5), to: self)
				CurveHelper.catmullRom(points: [curveOrigin, curveEnd], alpha: 1.0, closed: false, path: _curvePath)
				_curveLayer.path = _curvePath.cgPath
			}
			if Focused {
				_curveLayer.strokeColor = destObject != nil ? _focusedCurveColor : CGColor.clear
				_curveLayer.lineWidth = _focusedThickness
				_curveLayer.lineDashPattern = _focusedDashPattern
				_curveLayer.lineDashPhase = 0.0
				let anim = CABasicAnimation(keyPath: "lineDashPhase")
				anim.fromValue = _curveLayer.lineDashPattern?.reduce(0){$0 + $1.intValue}
				anim.toValue = 0.0
				anim.duration = _focusedDashDuration
				anim.repeatDuration = CFTimeInterval(Float.greatestFiniteMagnitude)
				_curveLayer.add(anim, forKey: nil)
				
			} else {
				_curveLayer.strokeColor = destObject != nil ? destColor : CGColor.clear
				_curveLayer.lineWidth = _regularThickness
				_curveLayer.lineDashPattern = nil
				_curveLayer.lineDashPhase = 0.0
				_curveLayer.removeAllAnimations()
			}
			
			// drag curve
			if isDragging {
				let curveOrigin = NSMakePoint(bounds.midX, bounds.midY)
				_dragPath.removeAllPoints()
				CurveHelper.catmullRom(points: [curveOrigin, _dragPosition], alpha: 1.0, closed: false, path: _dragPath)
				_dragLayer.path = _dragPath.cgPath
			}
			_dragLayer.strokeColor = isDragging ? OutlineColor.cgColor : CGColor.clear
			
			context.restoreGState()
		}
	}
}
