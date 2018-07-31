//
//  Pin.swift
//  Novella
//
//  Created by Daniel Green on 30/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class Pin: NSView {
	// MARK: - Variables -
	private var _nvBaseLink: NVBaseLink
	private var _owner: Node
	private var _panGesture: NSPanGestureRecognizer?
	private var _panTarget: Node?
	
	// MARK: - Properties -
	var BaseLink: NVBaseLink {
		get{ return _nvBaseLink }
	}
	var Owner: Node {
		get{ return _owner }
	}
	var Target: Node? {
		get{ return _panTarget }
	}
	
	// MARK: - Initialization -
	init(link: NVBaseLink, owner: Node) {
		self._nvBaseLink = link
		self._owner = owner
		self._panGesture = nil
		self._panTarget = nil
		super.init(frame: NSMakeRect(0.0, 0.0, 10.0, 10.0)) // anything nonzero for now as derived classes should set this
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		
		// pan gesture
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(Pin.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Pin::init(coder) not implemented.")
	}
	
	
	// MARK: - Functions -
	// MARK: Gesture Callbacks
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			panStarted(gesture)
			
		case .changed:
			// what is under our cursor in the graph?
			if let target = _owner._graphView.nodeAtPoint(gesture.location(in: _owner._graphView)) {
				// ignore trashed objects
				if target.Trashed {
					_panTarget?.unprime()
					_panTarget = nil
				}
				// ignore parent
				else if target == _owner {
					_panTarget?.unprime()
					_panTarget = nil
				} else {
					// unprime previous target (in case moved without hitting empty space)
					_panTarget?.unprime()
					// set new target
					_panTarget = target
					// prime target
					_panTarget?.prime()
				}
			} else {
				// not touching anything, so attempt to unprime and clear
				_panTarget?.unprime()
				_panTarget = nil
			}
			panChanged(gesture)
			
		case .cancelled, .ended:
			// unprime as we're done
			_panTarget?.unprime()
			panEnded(gesture)
			// nil after gesture called
			_panTarget = nil
			
		default:
			break
		}
	}
	
	// MARK: Virtuals
	func panStarted(_ gesture: NSPanGestureRecognizer) {
		NVLog.log("Pin::panStarted() should be overridden.", level: .warning)
	}
	func panChanged(_ gesture: NSPanGestureRecognizer) {
		NVLog.log("Pin::panChanged() should be overridden.", level: .warning)
	}
	func panEnded(_ gesture: NSPanGestureRecognizer) {
		NVLog.log("Pin::panEnded() should be overridden.", level: .warning)
	}
}
