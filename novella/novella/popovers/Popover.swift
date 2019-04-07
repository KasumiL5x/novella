 //
//  Popover.swift
//  novella
//
//  Created by Daniel Green on 07/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import AppKit

class Popover: NSObject {
	private var _popover: NSPopover?
	private var _vc: NSViewController?
	
	var ViewController: NSViewController? {
		return _vc
	}
	
	override init() {
		super.init()
	}
	
	private func create() -> Bool {
		// create view controller
		if nil == _vc {
			_vc = createViewController()
		}
		if nil == _vc {
			print("Popover::create() attempted to create an NSViewController but it was nil.")
			return false
		}
		
		// nspopover
		if nil == _popover {
			_popover = NSPopover()
			_popover?.animates = true
			_popover?.behavior = .transient
			_popover?.contentViewController = _vc
		}
		
		return true
	}
	
	func show(forView: NSView, at: NSRectEdge) {
		guard create() else {
			print("Popover::show() failed to create.")
			return
		}
		
		_popover?.show(relativeTo: forView.bounds, of: forView, preferredEdge: at)
	}
	
	func createViewController() -> NSViewController? {
		print("Popover::createViewController() should be overridden.")
		return nil
	}
}
