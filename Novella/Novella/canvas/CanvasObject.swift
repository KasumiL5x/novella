//
//  CanvasObject.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

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
	
	init(canvas: Canvas, frame: NSRect) {
		self._canvas = canvas
		self._lastPanPos = CGPoint.zero
		self.ContextMenu = NSMenu()
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
	
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
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
	
	// virtual functions
	func onClick(gesture: NSClickGestureRecognizer) {
	}
	func onDoubleClick(gesture: NSClickGestureRecognizer) {
	}
	func onContextClick(gesture: NSClickGestureRecognizer) {
	}
	func onPan(gesture: NSPanGestureRecognizer) {
	}
	func onMove() {
	}
	func onStateChanged() {
	}
	func redraw() {
	}
	func objectRect() -> NSRect {
		return bounds
	}
}
