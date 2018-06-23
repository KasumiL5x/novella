//
//  PinViewLink.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinViewLink: PinView {
	// MARK: - - Variables -
	private let _pinStrokeLayer: CAShapeLayer
	private let _pinFillLayer: CAShapeLayer
	private let _curveLayer: CAShapeLayer
	private let _curvePath: NSBezierPath
	private let _contextMenu: NSMenu
	private let _conditionPopover: ConditionPopover
	private let _functionPopover: FunctionPopover
	private let _graphDropMenu: NSMenu
	private var _outlineRect: NSRect
	private var _controlPoint: PinControlPoint?
	
	// MARK: - - Initialization -
	init(link: NVLink, graphView: GraphView, owner: LinkableView) {
		self._pinStrokeLayer = CAShapeLayer()
		self._pinFillLayer = CAShapeLayer()
		self._curveLayer = CAShapeLayer()
		self._curvePath = NSBezierPath()
		self._contextMenu = NSMenu()
		self._conditionPopover = ConditionPopover()
		self._functionPopover = FunctionPopover(true)
		self._graphDropMenu = NSMenu()
		self._outlineRect = NSRect.zero
		super.init(link: link, graphView: graphView, owner: owner)
		
		self._controlPoint = PinControlPoint(owner: self)
		
		// add layers
		layer!.addSublayer(_curveLayer)
		layer!.addSublayer(_pinStrokeLayer)
		layer!.addSublayer(_pinFillLayer)
		
		// configure stroke layer
		_pinStrokeLayer.lineWidth = 1.0
		_pinStrokeLayer.fillColor = CGColor.clear
		_pinStrokeLayer.strokeColor = NSColor.red.cgColor
		
		// configure curve layer
		_curveLayer.fillColor = nil
		_curveLayer.fillRule = kCAFillRuleNonZero
		_curveLayer.lineCap = kCALineCapRound
		_curveLayer.lineDashPattern = nil
		_curveLayer.lineJoin = kCALineJoinRound
		_curveLayer.lineWidth = 2.0
		
		// configure context menu
		_contextMenu.addItem(withTitle: "Edit Condition", action: #selector(PinViewLink.onContextCondition), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Edit Function", action: #selector(PinViewLink.onContextFunction), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Un/Trash", action: #selector(PinView.onContextDelete), keyEquivalent: "")
		
		// calculate rect
		_outlineRect = NSMakeRect(0.0, 0.0, PinView.PIN_SIZE, PinView.PIN_SIZE)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinViewLink::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	override func onTrashed() {
	}
	override func getFrameSize() -> NSSize {
		return NSMakeSize(PinView.PIN_SIZE, PinView.PIN_SIZE)
	}
	override func getDragOrigin() -> CGPoint {
		return NSMakePoint(frame.width * 0.5, frame.height * 0.5)
	}
	override func onPanStarted(_ gesture: NSPanGestureRecognizer) {
	}
	override func onPanFinished(_ target: LinkableView?) {
		switch target {
		case is GraphLinkableView:
			_graphDropMenu.removeAllItems()
			let asGraph = (target?.Linkable as! NVGraph)
			for child in asGraph.Nodes {
				let menuItem = NSMenuItem(title: "Link to " + (child.Name.isEmpty ? "Unnamed" : child.Name), action: #selector(PinViewLink.onGraphContextItem), keyEquivalent: "")
				menuItem.target = self
				menuItem.representedObject = child
				_graphDropMenu.addItem(menuItem)
			}
			NSMenu.popUpContextMenu(_graphDropMenu, with: NSApp.currentEvent!, for: target!)
			
		default:
			_graphView.Undo.execute(cmd: SetPinLinkDestinationCmd(pin: self, destination: target?.Linkable))
		}
	}
	override func onContextInternal(_ gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	override func setupControlPoints() {
		guard let destination = _graphView.getLinkableViewFrom(linkable: getDestination(), includeParentGraphs: true) else {
			if let idx = subviews.index(of: _controlPoint!) {
				subviews.remove(at: idx)
			}
			return
		}
		
		let start = NSMakePoint(frame.width*0.5, frame.height*0.5)
		let end =  destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
		let cp1 = NSPoint(x: start.x + (end.x - start.x) * 0.5, y: start.y)
		let cp2 = NSPoint(x: start.x + (end.x - start.x) * 0.5, y: end.y)
		let middle = (cp1 + cp2) * 0.5
		
		_controlPoint!.frame.origin = NSMakePoint(middle.x - _controlPoint!.frame.width*0.5, middle.y - _controlPoint!.frame.height*0.5)
		if subviews.index(of: _controlPoint!) == nil {
			addSubview(_controlPoint!)
		}
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextCondition() {
		_conditionPopover.show(forView: self, at: .maxX)
		(_conditionPopover.ViewController as! ConditionPopoverViewController).setCondition(condition: (BaseLink as! NVLink).Condition)
	}
	@objc private func onContextFunction() {
		_functionPopover.show(forView: self, at: .maxX)
		(_functionPopover.ViewController as! FunctionPopoverViewController).setFunction(function: (BaseLink as! NVLink).Transfer.Function)
	}
	@objc private func onGraphContextItem(sender: NSMenuItem) {
		_graphView.Undo.execute(cmd: SetPinLinkDestinationCmd(pin: self, destination: sender.representedObject as? NVObject))
	}
	
	// MARK: Destination
	func setDestination(dest: NVObject?) {
		(BaseLink as! NVLink).setDestination(dest: dest)
		_graphView.updateCurves()
		
		setupControlPoints()
	}
	func getDestination() -> NVObject? {
		return (BaseLink as! NVLink).Transfer.Destination
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			context.resetClip()
			
			// MARK: Pin Drawing
			let strokePath = NSBezierPath(ovalIn: _outlineRect)
			_pinStrokeLayer.path = strokePath.cgPath
			_pinStrokeLayer.strokeColor = CGColor.white
			
			let fillPath = NSBezierPath(ovalIn: _outlineRect.insetBy(dx: PinView.PIN_INSET, dy: PinView.PIN_INSET))
			_pinFillLayer.path = fillPath.cgPath
			if getDestination() != nil {
				_pinFillLayer.fillColor = TrashMode ? Settings.graph.pins.linkPinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.linkPinColor.cgColor
			} else {
				_pinFillLayer.fillColor = CGColor.clear
			}
			
			context.resetClip()
			// MARK: Curve Drawing
			let origin = NSMakePoint(frame.width * 0.5, frame.height * 0.5)
			var end = CGPoint.zero
			_curveLayer.path = nil
			_curvePath.removeAllPoints()
			// draw link curve
			if let destination = _graphView.getLinkableViewFrom(linkable: getDestination(), includeParentGraphs: true) {
				// convert local from destination into local of self and make curve
				end = destination.convert(NSMakePoint(0.0, destination.frame.height * 0.5), to: self)
				
				_graphView.Document.CurveType = .test
				let middle = (origin + end) * 0.5 - NSMakePoint(_controlPoint!.frame.width*0.5, _controlPoint!.frame.height*0.5)
				let cp = _controlPoint!.frame.origin + NSMakePoint(_controlPoint!.frame.size.width/2, _controlPoint!.frame.size.height/2)
				let cpOffset = cp - middle
				switch _graphView.Document.CurveType {
				case .line:
					CurveHelper.line(start: origin, end: end, path: _curvePath)
				case .smooth:
//					CurveHelper.smooth(start: origin, end: end, path: _curvePath)

					print(cpOffset)
					CurveHelper.smoothOffset(start: origin, end: end, path: _curvePath, offset: cpOffset)
				case .curve:
					CurveHelper.curve(start: origin, end: end, path: _curvePath)
				case .square:
					CurveHelper.square(start: origin, end: end, path: _curvePath)
				case .test:
					CurveHelper.hermite(points: [origin, cp, end], closed: false, path: _curvePath)
//					CurveHelper.test(points: [origin, middle, end], tension: 1.0, path: _curvePath)
				}
				
				_curveLayer.strokeColor = TrashMode ? Settings.graph.pins.linkCurveColor.withSaturation(Settings.graph.trashedSaturation).cgColor : Settings.graph.pins.linkCurveColor.cgColor
				_curveLayer.path = _curvePath.cgPath
				_curveLayer.lineDashPattern = (destination is GraphLinkableView) ? PinView.EXT_CURVE_PATTERN : nil
			}
			
			context.restoreGState()
		}
	}
}
