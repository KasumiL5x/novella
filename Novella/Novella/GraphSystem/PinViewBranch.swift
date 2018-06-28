//
//  PinViewBranch.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinViewBranch: PinView {
	// MARK: - - Variables -
	private let _pinStrokeLayer: CAShapeLayer
	private let _pinFillLayerTrue: CAShapeLayer
	private let _pinFillLayerFalse: CAShapeLayer
	private let _trueCurveLayer: CAShapeLayer
	private let _trueCurvePath: NSBezierPath
	private let _falseCurveLayer: CAShapeLayer
	private let _falseCurvePath: NSBezierPath
	
	private var _outlineRect: NSRect
	private var _falsePinRect: NSRect
	private var _truePinRect: NSRect
	
	private var _pannedPin: Bool // true = true pin, false = false pin
	
	private let _trueContextMenu: NSMenu
	private let _falseContextMenu: NSMenu
	private let _conditionPopover: ConditionPopover
	private let _trueFunctionPopover: FunctionPopover
	private let _falseFunctionPopover: FunctionPopover
	private let _graphDropMenu: NSMenu
	
	// MARK: - - Initialization -
	init(link: NVBranch, graphView: GraphView, owner: LinkableView) {
		self._pinStrokeLayer = CAShapeLayer()
		self._pinFillLayerTrue = CAShapeLayer()
		self._pinFillLayerFalse = CAShapeLayer()
		self._trueCurveLayer = CAShapeLayer()
		self._trueCurvePath = NSBezierPath()
		self._falseCurveLayer = CAShapeLayer()
		self._falseCurvePath = NSBezierPath()
		self._outlineRect = NSRect.zero
		self._falsePinRect = NSRect.zero
		self._truePinRect = NSRect.zero
		self._pannedPin = false
		self._trueContextMenu = NSMenu()
		self._falseContextMenu = NSMenu()
		self._conditionPopover = ConditionPopover()
		self._trueFunctionPopover = FunctionPopover(true)
		self._falseFunctionPopover = FunctionPopover(false)
		self._graphDropMenu = NSMenu()
		super.init(link: link, graphView: graphView, owner: owner)
		
		layer!.addSublayer(_pinStrokeLayer)
		layer!.addSublayer(_pinFillLayerTrue)
		layer!.addSublayer(_pinFillLayerFalse)
		layer!.addSublayer(_trueCurveLayer)
		layer!.addSublayer(_falseCurveLayer)
		
		// configure stroke layer
		_pinStrokeLayer.lineWidth = 1.0
		_pinStrokeLayer.fillColor = CGColor.clear
		_pinStrokeLayer.strokeColor = NSColor.red.cgColor
		
		// configure true curve layer
		_trueCurveLayer.fillColor = nil
		_trueCurveLayer.fillRule = kCAFillRuleNonZero
		_trueCurveLayer.lineCap = kCALineCapRound
		_trueCurveLayer.lineDashPattern = nil
		_trueCurveLayer.lineJoin = kCALineJoinRound
		_trueCurveLayer.lineWidth = 2.0
		
		// configure false curve layer
		_falseCurveLayer.fillColor = nil
		_falseCurveLayer.fillRule = kCAFillRuleNonZero
		_falseCurveLayer.lineCap = kCALineCapRound
		_falseCurveLayer.lineDashPattern = nil
		_falseCurveLayer.lineJoin = kCALineJoinRound
		_falseCurveLayer.lineWidth = 2.0
		
		// calculate rects
		let actualPinSize = PinView.PIN_SIZE - (PinView.PIN_INSET*2.0) // inset from both sides
		_outlineRect = NSMakeRect(0.0, 0.0, PinView.PIN_SIZE, actualPinSize*2.0 + PinView.PIN_SPACING*3.0)
		_falsePinRect = NSMakeRect(PinView.PIN_INSET, PinView.PIN_SPACING, actualPinSize, actualPinSize)
		_truePinRect = NSMakeRect(_falsePinRect.origin.x, _falsePinRect.maxY + PinView.PIN_SPACING, _falsePinRect.width, _falsePinRect.height)
		
		// configure menus
		_trueContextMenu.addItem(withTitle: "Edit True Function", action: #selector(PinViewBranch.onContextTrueFunction), keyEquivalent: "")
		_trueContextMenu.addItem(NSMenuItem.separator())
		_trueContextMenu.addItem(withTitle: "Edit PreCondition", action: #selector(PinViewBranch.onContextPreCondition), keyEquivalent: "")
		_trueContextMenu.addItem(withTitle: "Edit Condition", action: #selector(PinViewBranch.onContextCondition), keyEquivalent: "")
		_trueContextMenu.addItem(NSMenuItem.separator())
		_trueContextMenu.addItem(withTitle: "Delete", action: #selector(PinView.onContextDelete), keyEquivalent: "")
		//
		_falseContextMenu.addItem(withTitle: "Edit False Function", action: #selector(PinViewBranch.onContextFalseFunction), keyEquivalent: "")
		_falseContextMenu.addItem(NSMenuItem.separator())
		_falseContextMenu.addItem(withTitle: "Edit PreCondition", action: #selector(PinViewBranch.onContextPreCondition), keyEquivalent: "")
		_falseContextMenu.addItem(withTitle: "Edit Condition", action: #selector(PinViewBranch.onContextCondition), keyEquivalent: "")
		_falseContextMenu.addItem(NSMenuItem.separator())
		_falseContextMenu.addItem(withTitle: "Un/Trash", action: #selector(PinView.onContextDelete), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinViewBranch::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	override func onTrashed() {
	}
	override func getFrameSize() -> NSSize {
		let actualPinSize = PinView.PIN_SIZE - PinView.PIN_INSET
		return NSMakeSize(PinView.PIN_SIZE, actualPinSize*2.0 + PinView.PIN_SPACING)
	}
	override func getDragOrigin() -> CGPoint {
		if _pannedPin {
			return NSMakePoint(_truePinRect.origin.x + _truePinRect.width*0.5, _truePinRect.origin.y + _truePinRect.height*0.5)
		} else {
			return NSMakePoint(_falsePinRect.origin.x + _falsePinRect.width*0.5, _falsePinRect.origin.y + _falsePinRect.height*0.5)
		}
	}

	override func onPanStarted(_ gesture: NSPanGestureRecognizer) {
		let point = gesture.location(in: self)
		if _truePinRect.contains(point) {
			_pannedPin = true
		} else if _falsePinRect.contains(point) {
			_pannedPin = false
		}
	}
	override func onPanFinished(_ target: LinkableView?) {
		switch target {
		case is GraphLinkableView:
			_graphDropMenu.removeAllItems()
			let asGraph = (target?.Linkable as! NVGraph)
			for child in asGraph.Nodes {
				let menuItem = NSMenuItem(title: "Link to " + (child.Name.isEmpty ? "Unnamed" : child.Name), action: #selector(PinViewBranch.onGraphContextItem), keyEquivalent: "")
				menuItem.target = self
				menuItem.representedObject = child
				_graphDropMenu.addItem(menuItem)
			}
			NSMenu.popUpContextMenu(_graphDropMenu, with: NSApp.currentEvent!, for: target!)
			
		default:
			_graphView.Undo.execute(cmd: SetPinBranchDestinationCmd(pin: self, destination: target?.Linkable, forTrue: _pannedPin))
		}
	}
	override func onContextInternal(_ gesture: NSClickGestureRecognizer) {
		let point = gesture.location(in: self)
		if _truePinRect.contains(point) {
			_pannedPin = true
			NSMenu.popUpContextMenu(_trueContextMenu, with: NSApp.currentEvent!, for: self)
		} else if _falsePinRect.contains(point) {
			_pannedPin = false
			NSMenu.popUpContextMenu(_falseContextMenu, with: NSApp.currentEvent!, for: self)
		}
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextPreCondition() {
		_conditionPopover.show(forView: self, at: .maxX)
		(_conditionPopover.ViewController as! ConditionPopoverViewController).setCondition(condition: (BaseLink as! NVBranch).PreCondition)
	}
	@objc private func onContextCondition() {
		_conditionPopover.show(forView: self, at: .maxX)
		(_conditionPopover.ViewController as! ConditionPopoverViewController).setCondition(condition: (BaseLink as! NVBranch).Condition)
	}
	@objc private func onContextTrueFunction() {
		_trueFunctionPopover.show(forView: self, at: .maxX)
		(_trueFunctionPopover.ViewController as! FunctionPopoverViewController).setFunction(function: (BaseLink as! NVBranch).TrueTransfer.Function)
	}
	@objc private func onContextFalseFunction() {
		_falseFunctionPopover.show(forView: self, at: .maxX)
		(_falseFunctionPopover.ViewController as! FunctionPopoverViewController).setFunction(function: (BaseLink as! NVBranch).FalseTransfer.Function)
	}
	@objc private func onGraphContextItem(sender: NSMenuItem) {
		_graphView.Undo.execute(cmd: SetPinBranchDestinationCmd(pin: self, destination: sender.representedObject as? NVObject, forTrue: _pannedPin))
	}
	
	// MARK: Destination
	func setTrueDestination(dest: NVObject?) {
		(BaseLink as! NVBranch).setTrueDestination(dest: dest)
		_graphView.updateCurves()
	}
	func getTrueDestination() -> NVObject? {
		return (BaseLink as! NVBranch).TrueTransfer.Destination
	}
	func setFalseDestination(dest: NVObject?) {
		(BaseLink as! NVBranch).setFalseDestination(dest: dest)
		_graphView.updateCurves()
	}
	func getFalseDestination() -> NVObject? {
		return (BaseLink as! NVBranch).FalseTransfer.Destination
	}
	
	// MARK: - - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let normalColor = NSColor.fromHex("#535353")
			let ownerSelectedColor = NSColor.fromHex("#f67280")
			let pinColor = (Owner.IsSelected || Owner.IsPrimed) ? ownerSelectedColor : normalColor
			
			
			// draw pin stroke
			_pinStrokeLayer.path = NSBezierPath(roundedRect: _outlineRect, xRadius: 5.0, yRadius: 5.0).cgPath
			_pinStrokeLayer.strokeColor = pinColor.cgColor
			// draw true pin
			_pinFillLayerTrue.path = NSBezierPath(ovalIn: _truePinRect).cgPath
			if getTrueDestination() != nil {
				_pinFillLayerTrue.fillColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
				_pinFillLayerTrue.strokeColor = nil
			} else {
				_pinFillLayerTrue.fillColor = nil
				_pinFillLayerTrue.strokeColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
			}
			// draw false pin
			_pinFillLayerFalse.path = NSBezierPath(ovalIn: _falsePinRect).cgPath
			if getFalseDestination() != nil {
				_pinFillLayerFalse.fillColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
				_pinFillLayerFalse.strokeColor = nil
			} else {
				_pinFillLayerFalse.fillColor = nil
				_pinFillLayerFalse.strokeColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
			}
			
			// draw curves
			var end = CGPoint.zero
			//
			_trueCurveLayer.path = nil
			if let trueDest = _graphView.getLinkableViewFrom(linkable: getTrueDestination(), includeParentGraphs: true) {
				_trueCurvePath.removeAllPoints()
				let origin = NSMakePoint(_truePinRect.midX, _truePinRect.midY)
				// convert local from destination into local of self and make curve
				end = trueDest.convert(NSMakePoint(0.0, trueDest.frame.height * 0.5), to: self)
				
				switch _graphView.Document.CurveType {
				case .catmullRom:
					CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false, path: _trueCurvePath)
				case .square:
					CurveHelper.square(start: origin, end: end, path: _trueCurvePath)
				case .line:
					CurveHelper.line(start: origin, end: end, path: _trueCurvePath)
				}
				
				if Owner.IsSelected || Owner.IsPrimed {
					_trueCurveLayer.strokeColor = NSColor.red.cgColor
				} else {
					_trueCurveLayer.strokeColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
				}
				_trueCurveLayer.path = _trueCurvePath.cgPath
				_trueCurveLayer.lineDashPattern = (trueDest is GraphLinkableView) ? PinView.EXT_CURVE_PATTERN : nil
			}
			_falseCurveLayer.path = nil
			if let falseDest = _graphView.getLinkableViewFrom(linkable: getFalseDestination(), includeParentGraphs: true) {
				_falseCurvePath.removeAllPoints()
				let origin = NSMakePoint(_falsePinRect.midX, _falsePinRect.midY)
				// convert local from destination into local of self and make curve
				end = falseDest.convert(NSMakePoint(0.0, falseDest.frame.height * 0.5), to: self)
				
				switch _graphView.Document.CurveType {
				case .catmullRom:
					CurveHelper.catmullRom(points: [origin, end], alpha: 1.0, closed: false, path: _falseCurvePath)
				case .square:
					CurveHelper.square(start: origin, end: end, path: _falseCurvePath)
				case .line:
					CurveHelper.line(start: origin, end: end, path: _falseCurvePath)
				}
				
				if Owner.IsSelected || Owner.IsPrimed {
					_falseCurveLayer.strokeColor = NSColor.red.cgColor
				} else {
					_falseCurveLayer.strokeColor = TrashMode ? pinColor.withSaturation(Settings.graph.trashedSaturation).cgColor : pinColor.cgColor
				}
				_falseCurveLayer.path = _falseCurvePath.cgPath
				_falseCurveLayer.lineDashPattern = (falseDest is GraphLinkableView) ? PinView.EXT_CURVE_PATTERN : nil
			}
			
			context.restoreGState()
		}
	}
}
