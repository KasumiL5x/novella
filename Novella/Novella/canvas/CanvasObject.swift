//
//  CanvasObject.swift
//  novella
//
//  Created by dgreen on 11/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

// Base object for all canvas elements.
class CanvasObject: NSView {
	enum State {
		case normal
		case primed
		case selected
	}
	
	// MARK: - Variables
	private var _clickGesture: NSClickGestureRecognizer? = nil
	private var _doubleClickGesture: NSClickGestureRecognizer? = nil
	private var _contextClickGesture: NSClickGestureRecognizer? = nil
	private var _panGesture: NSPanGestureRecognizer? = nil
	private var _lastPanPos: CGPoint = CGPoint.zero
	
	// MARK: - Properties
	private(set) var TheCanvas: Canvas
	var IncomingTransfers: [Transfer] = []
	private(set) var CurrentState: State = .normal {
		didSet {
			onStateChange()
			redraw()
		}
	}
	
	// MARK: - Initialization
	init(canvas: Canvas, frame frameRect: NSRect) {
		self.TheCanvas = canvas
		super.init(frame: frameRect)
		
		// go away dark mode
		appearance = NSAppearance(named: .aqua)
		
		// setup layers
		wantsLayer = true
		layer?.masksToBounds = false
		
		setupGestures()
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasObject::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	private func setupGestures() {
		// click
		_clickGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onClick))
		_clickGesture?.buttonMask = 0x1 // "primary click"
		_clickGesture?.numberOfClicksRequired = 1
		addGestureRecognizer(_clickGesture!)
		
		// double click
		_doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onDoubleClick))
		_doubleClickGesture?.buttonMask = 0x1 // "primary click"
		_doubleClickGesture?.numberOfClicksRequired = 2
		addGestureRecognizer(_doubleClickGesture!)
		
		// context click
		_contextClickGesture = NSClickGestureRecognizer(target: self, action: #selector(CanvasObject._onContextClick))
		_contextClickGesture?.buttonMask = 0x2 // "secondary click"
		_contextClickGesture?.numberOfClicksRequired = 1
		addGestureRecognizer(_contextClickGesture!)
		
		// pan
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(CanvasObject._onPan))
		_panGesture?.buttonMask = 0x1 // "primary click"
		addGestureRecognizer(_panGesture!)
	}
	
	func prime() {
		CurrentState = .primed
	}
	func select() {
		CurrentState = .selected
	}
	func normal() {
		CurrentState = .normal
	}
	
	func move(_ to: CGPoint) {
		frame.origin = to
		onMove()
	}
	
	// MARK: Gesture Callbacks
	@objc private func _onClick(gesture: NSClickGestureRecognizer) {
		let append = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
		if append {
			if CurrentState == .selected {
				TheCanvas.Selection?.deselect(self)
			} else {
				TheCanvas.Selection?.select(self, append: true)
			}
		} else {
			TheCanvas.Selection?.select(self, append: false)
		}
		
		// derived callback
		onClick(gesture: gesture)
	}
	@objc private func _onDoubleClick(gesture: NSClickGestureRecognizer) {
		onDoubleClick(gesture: gesture)
	}
	@objc private func _onContextClick(gesture: NSClickGestureRecognizer) {
		onContextClick(gesture: gesture)
	}
	@objc private func _onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			// if node is not selected but we dragged it, replace selection before beginning drag
			if CurrentState != .selected {
				TheCanvas.Selection?.select(self, append: false)
			}
			_lastPanPos = gesture.location(in: self)
			
		case .changed:
			let currPanPos = gesture.location(in: self)
			let deltaPanPos = currPanPos - _lastPanPos
			
			// move all objects in the selection
			TheCanvas.Selection?.Selection.forEach({ (obj) in
				var newPos = NSMakePoint(obj.frame.origin.x + deltaPanPos.x, obj.frame.origin.y + deltaPanPos.y)
				// clamp to bounds
				if newPos.x < 0.0 {
					newPos.x = 0.0
				}
				if (newPos.x + obj.frame.width) > TheCanvas.bounds.width {
					newPos.x = TheCanvas.bounds.width - obj.frame.width
				}
				if newPos.y < 0.0 {
					newPos.y = 0.0
				}
				if (newPos.y + obj.frame.height) > TheCanvas.bounds.height {
					newPos.y = TheCanvas.bounds.height - obj.frame.height
				}
				obj.move(newPos)
			})
			
		default:
			break
		}
		
		// derived callback
		onPan(gesture: gesture)
	}
	
	// MARK: Virtuals
	func onStateChange() {
	}
	func onClick(gesture: NSClickGestureRecognizer) {
	}
	func onDoubleClick(gesture: NSClickGestureRecognizer) {
	}
	func onContextClick(gesture: NSClickGestureRecognizer) {
	}
	func onPan(gesture: NSPanGestureRecognizer) {
	}
	func redraw() {
		IncomingTransfers.forEach{$0.redraw()}
	}
	func onMove() {
		IncomingTransfers.forEach{$0.redraw()}
	}
	func color() -> NSColor {
		return NSColor.fromHex("#3c3c3c")
	}
	func reloadFromModel() {
		print("CanvasObject::reloadFromModel() should be overridden and should reset/reload its data from its model object.")
	}
}

// BUG: layer.masksToBounds.
// In macOS 10.12.6, I encountered a bug with layer.masksToBounds.  When its frame is set or subviews are
// added/have their frames moved, the layer.maskToBounds is forced to true.  I did a lot of deep digging into this
// and it seems to be an OS (and/or runtime version) issue.
//
// The solution seems to be to set when the frame changes, as so:
//   override var frame: NSRect {
//       didSet {
//           layer?.masksToBounds = false // See layout() for notes about this.
//       }
//   }
//
// Additionally, the laying out of subviews causes the same problem, but overriding layout () fixes it as so:
//   override func layout() {
//   }
//
// In later versions of the OS (testing on 10.13.6), these fixes do not need to be made, therefore this is likely
// to be some kind of runtime version issue or OS-specific problem.  I tested both with Swift 4.0 initially.
