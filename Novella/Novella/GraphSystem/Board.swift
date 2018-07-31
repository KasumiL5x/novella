//
//  Board.swift
//  Novella
//
//  Created by Daniel Green on 30/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class Board: NSView {
	// MARK: - Statics -
	static let PADDING: CGFloat = 3.0
	static let RADIUS: CGFloat = 6.0
	
	// MARK: - Variables -
	private var _bgLayer: CAShapeLayer
	private var _pins: [Pin]
	
	// MARK: - Properties -
	var Pins: [Pin] {
		get{ return _pins }
	}
	
	// MARK: - Initialization -
	override init(frame frameRect: NSRect) {
		self._bgLayer = CAShapeLayer()
		self._pins = []
		super.init(frame: frameRect)
		
		// layer setup
		wantsLayer = true
		layer!.masksToBounds = false
		
		// add bg layer
		layer!.addSublayer(_bgLayer)
		
		layoutPins()
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Board::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	override func hitTest(_ point: NSPoint) -> NSView? {
		for sub in subviews {
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				return sub
			}
		}
		
		// don't allow clicking of the board itself
		return nil
	}
	
	func add(_ pin: Pin) {
		_pins.append(pin)
		self.addSubview(pin)
		layoutPins()
	}
	
	func remove(_ pin: Pin) {
		guard let idx = _pins.index(of: pin) else {
			return
		}
		_pins.remove(at: idx)
		pin.removeFromSuperview()
		layoutPins()
	}
	
	private func subviewsFrame() -> NSSize {
		var w: CGFloat = 0.0
		var h: CGFloat = 0.0
		for sub in subviews {
			let sw = sub.frame.origin.x + sub.frame.width
			let sh = sub.frame.origin.y + sub.frame.height
			w = max(w, sw)
			h = max(h, sh)
		}
		return NSMakeSize(w, h)
	}
	func layoutPins() {
		// center all pins in x
		var lastY: CGFloat = Board.PADDING
		for p in _pins {
			p.frame.origin.x = Board.PADDING
			p.frame.origin.y = lastY
			
			lastY += p.frame.height + Board.PADDING
		}
		
		// set actual frame size
		var subFrame = subviewsFrame()
		subFrame.width += Board.PADDING
		subFrame.height += Board.PADDING
		self.frame.size = subFrame
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		_bgLayer.fillColor = NSColor.fromHex("#FAFAFA").cgColor
		_bgLayer.strokeColor = NSColor.fromHex("#2D2D2D").cgColor
		let path = NSBezierPath(roundedRect: bounds, xRadius: Board.RADIUS, yRadius: Board.RADIUS)
		_bgLayer.path = path.cgPath
	}
}
