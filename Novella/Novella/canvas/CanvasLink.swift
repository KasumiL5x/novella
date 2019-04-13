//
//  CanvasLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasLink: NSView {
	let Link: NVLink
	let _popover: LinkPopover
	
	static let Size: CGFloat = 15.0
	static let OutlineInset: CGFloat = 3.0
	static let FillInset: CGFloat = 1.5
	
	private(set) var _canvas: Canvas
	private(set) var Origin: CanvasObject
	//
	private let _outlineLayer: CAShapeLayer
	private let _fillLayer: CAShapeLayer
	//
	private let _dragLayer: CAShapeLayer
	private var _isDragging: Bool
	private weak var _previousTarget: CanvasObject?
	private(set) weak var _currentTarget: CanvasObject?
	//
	var _curvelayer: CAShapeLayer // no protected in swift...
	//
	private var _lastParker: LinkParker? // for drag drop onto a LinkParker
	//
	var ContextMenu: NSMenu
	
	init(canvas: Canvas, origin: CanvasObject, link: NVLink) {
		self.Link = link
		self._popover = LinkPopover()
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
		//
		self.ContextMenu = NSMenu()
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
		
		// gestures
		let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CanvasLink.onPan))
		panGesture.buttonMask = 0x1
		addGestureRecognizer(panGesture)
		//
		let ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasLink._onContextClick))
		ctxGesture.buttonMask = 0x2
		ctxGesture.numberOfClicksRequired = 1
		addGestureRecognizer(ctxGesture)
		
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
		
		 // menu
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasLink.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasLink.onDelete), keyEquivalent: "")
		
		// handle case where destination already exists
		if let dest = link.Destination, let destObj = canvas.canvasObjectFor(linkable: dest) {
			setTarget(destObj)
		}
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func redraw() {
		updateCurve()
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(link: self, doc: _canvas.Doc)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Link?", info: "Are you sure you want to delete this link? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(link: Link)
		}
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
			if let target = _canvas.objectAt(point: gesture.location(in: _canvas), ignoring: nil), canlinkTo(obj: target) {
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
			
			// update target state and drag layer state
			if let target = _currentTarget {
				target.CurrentState = .normal
				_dragLayer.strokeColor = CGColor.clear // don't want a nice transition otherwise there would be two curves
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
			
			// update curve to target (automatically handles nil/valid/self)
			updateCurve()
			
			// handle drop on parker if present
			if let parker = _lastParker {
				parker.park(self)
			}

		default:
			break
		}
		
		setNeedsDisplay(bounds)
	}
	
	@objc private func _onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(ContextMenu, with: NSApp.currentEvent!, for: self)
		onContextClick(gesture: gesture)
	}
	
	func setTarget(_ target: CanvasObject?) {
		if nil == target {
			_lastParker = nil
			_previousTarget = nil
			_currentTarget = nil
			redraw()
		}
		
		if let target = target, canlinkTo(obj: target) {
			_lastParker = nil
			_previousTarget = nil
			_currentTarget = target
			connectTo(obj: target)
			redraw()
		}
	}
	
	func updateCurve() {
		if let target = _currentTarget { // has a valid target
			_curvelayer.strokeColor = target.mainColor().cgColor
			
			// linking to self
			if target == Origin {
				// is the centerpoint of this link below(ish) the center of the object?  this will decide the loop direction
				let objY = target.convert(NSMakePoint(0, target.bounds.midY), to: nil).y
				let thisY = self.convert(NSMakePoint(0.0, bounds.midY), to: nil).y
				let belowCenter = (objY - thisY) > 0.5 // the values are not identical even when constrained, so add a little buffer room
				
				// compute start and end points
				let origin = NSMakePoint(bounds.midX, bounds.midY)
				let end = target.convert(NSMakePoint(target.bounds.width * 0.8, belowCenter ? 0.0 : target.bounds.height), to: self)
				
				// compute circle containing the points and the angle of the points in that circle in radians
				let center = (end + origin) * 0.5
				let radius = center.distance(to: origin)
				let originAngle = atan2(origin.y - center.y, origin.x - center.x) * 57.2958
				let endAngle = atan2(end.y - center.y, end.x - center.x) * 57.2958
				
				// line the computed curve
				let path = NSBezierPath()
				path.appendArc(withCenter: center, radius: radius, startAngle: originAngle, endAngle: endAngle, clockwise: belowCenter)
				
				_curvelayer.path = path.cgPath
			} else { // linking to other object
				let origin = NSMakePoint(bounds.midX, bounds.midY)
				let end = target.convert(NSMakePoint(0.0, target.frame.height * 0.5), to: self)
				_curvelayer.path = CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false).cgPath
			}
			
		} else { // nil target - animate out
			_curvelayer.strokeColor = CGColor.clear
		}
	}
	
	// virtuals
	func onContextClick(gesture: NSClickGestureRecognizer) {
		print("Alan, please override.")
	}
	func canlinkTo(obj: CanvasObject) -> Bool {
		// must be same type
		if type(of: obj.Linkable) != type(of: Origin.Linkable) {
			return false
		}
		
		// cannot be parllel
		switch obj {
		case let seq as CanvasSequence:
			if seq.Sequence.Parallel {
				return false
			}
			
		case let evt as CanvasEvent:
			if evt.Event.Parallel {
				return false
			}
			
		default:
			break
		}
		
		return true
	}
	func connectTo(obj: CanvasObject?) {
		// revert previous object back to normal state and remove self as delegate
		if let oldDest = Link.Destination, let oldObj = _canvas.canvasObjectFor(linkable: oldDest) {
			oldObj.CurrentState = .normal
			oldObj.remove(delegate: self)
		}
		
		// update model link destination
		Link.Destination = obj?.Linkable ?? nil
		
		// add self as delegate
		obj?.add(delegate: self)
	}
}

extension CanvasLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		updateCurve()
	}
}
