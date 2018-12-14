//
//  CanvasObject.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

protocol CanvasObjectDelegate: class {
	func canvasObjectMoved(obj: CanvasObject)
}

class CanvasObject: NSView {
	enum State {
		case normal
		case primed
		case selected
	}
	
	private(set) var _canvas: Canvas
	private var _lastPanPos: CGPoint
	var ContextMenu: NSMenu
	var CurrentState: State = .normal {
		didSet {
			onStateChanged()
			redraw()
		}
	}
	private var _delegates: [CanvasObjectDelegate]
	
	init(canvas: Canvas, frame: NSRect) {
		self._canvas = canvas
		self._lastPanPos = CGPoint.zero
		self.ContextMenu = NSMenu()
		self._delegates = []
		super.init(frame: frame)
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onClick))
		clickGesture.buttonMask = 0x1
		clickGesture.numberOfClicksRequired = 1
		addGestureRecognizer(clickGesture)
		
		let dubGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onDoubleClick))
		dubGesture.buttonMask = 0x1
		dubGesture.numberOfClicksRequired = 2
		addGestureRecognizer(dubGesture)
		
		let ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onContextClick))
		ctxGesture.buttonMask = 0x2
		ctxGesture.numberOfClicksRequired = 1
		addGestureRecognizer(ctxGesture)
		
		let panGesture = NSPanGestureRecognizer(target: self, action: #selector(CanvasObject._onPan))
		panGesture.buttonMask = 0x1
		addGestureRecognizer(panGesture)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func add(delegate: CanvasObjectDelegate) {
		_delegates.append(delegate)
	}
	func remove(delegate: CanvasObjectDelegate) {
		for i in 0..<_delegates.count {
			if _delegates[i] === delegate {
				_delegates.remove(at: i)
				break
			}
		}
	}
	
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_delegates.forEach{$0.canvasObjectMoved(obj: self)}
	}
	
	@objc private func _onClick(gesture: NSClickGestureRecognizer) {
		let append = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
		if append {
			if CurrentState == .selected {
				_canvas.Selection.deselect(self)
			} else {
				_canvas.Selection.select(self, append: true)
			}
		} else {
			_canvas.Selection.select(self, append: false)
		}
		onClick(gesture: gesture)
	}
	@objc private func _onDoubleClick(gesture: NSClickGestureRecognizer) {
		onDoubleClick(gesture: gesture)
	}
	@objc private func _onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(ContextMenu, with: NSApp.currentEvent!, for: self)
		onContextClick(gesture: gesture)
	}
	@objc private func _onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_lastPanPos = gesture.location(in: self)
			if CurrentState != .selected {
				// replace selection if click dragging a non-selected object
				_canvas.Selection.select(self, append: false)
			}
			
		case .changed:
			let currPanPos = gesture.location(in: self)
			let deltaPanPos = currPanPos - _lastPanPos
			_canvas.moveSelection(delta: deltaPanPos)
			
		case .cancelled, .ended:
			break
			
		default:
			break
		}
		
		onPan(gesture: gesture)
	}
	
	//
	// virtual functions
	
	func mainColor() -> NSColor {
		// the primary color of the object (often used for flags and so on)
		return NSColor.fromHex("#FF00FF")
	}
	func onClick(gesture: NSClickGestureRecognizer) {
		// single click gesture
	}
	func onDoubleClick(gesture: NSClickGestureRecognizer) {
		// double click gesture
	}
	func onContextClick(gesture: NSClickGestureRecognizer) {
		// context click gesture
	}
	func onPan(gesture: NSPanGestureRecognizer) {
		// pan gesture
	}
	func onMove() {
		// when move() is called
	}
	func onStateChanged() {
		// when the state changed
	}
	func redraw() {
		// redraw the element (including controlling whether layers should be visible or not etc.)
	}
	func objectRect() -> NSRect {
		// rect within the object's bounds that are the "main" object (used mostly for when the frame is expanded but the object shouldn't change size)
		return bounds
	}
	func reloadData() {
		// reload data from the model itself (e.g., update labels)
	}
}
