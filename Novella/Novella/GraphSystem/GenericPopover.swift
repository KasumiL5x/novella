//
//  GenericPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class GenericPopover: NSObject {
	// MARK: - - Variables -
	private var _view: NSView?
	private var _popover: NSPopover?
	var _viewController: NSViewController? // PROTECTED
	private var _window: NSWindow?
	
	// MARK: - - Initialization -
	override init() {
		self._view = nil
		self._popover = nil
		self._viewController = nil
		self._window = nil
		
		super.init()
	}
	
	// MARK: - - Propeties -
	var View: NSView? {
		get{ return _view }
	}
	var ViewController: NSViewController? {
		get{ return _viewController }
	}
	
	func show(forView: NSView, at: NSRectEdge) {
		// reset everything if the view changed
		if _view != forView {
			_view = forView
			_viewController = nil
			_window = nil
			_popover = nil
		}
		
		
		// create view controller
		if _viewController == nil, !createViewController() {
			print("Attempted to create a NSViewController for a GenericPopover but was unable to do so.")
			return
		}
		
		// create window
		if _window == nil {
			let frame = _viewController!.view.bounds
			let styleMask = NSWindow.StyleMask(rawValue: NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.closable.rawValue)
			let rect = NSWindow.contentRect(forFrameRect: frame, styleMask: styleMask)
			_window = NSWindow(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: true)
			_window!.contentViewController = _viewController!
			_window!.isReleasedWhenClosed = false
			_window!.hidesOnDeactivate = true
			_window!.level = .floating
		}
		
		// popover
		if _popover == nil {
			_popover = NSPopover()
			_popover!.contentViewController = _viewController
			_popover!.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			_popover!.animates = true
			_popover!.behavior = .transient
			_popover!.delegate = self
		}
		
		// show existing window or present inital popover
		if _window!.isVisible {
			_window!.makeKeyAndOrderFront(self)
		} else {
			_popover!.show(relativeTo: _view!.bounds, of: _view!, preferredEdge: at)
		}
	}
	
	// MARK: - - Virtual Functions -
	func createViewController() -> Bool {
		print("GenericPopover::createViewController should be overridden.")
		return false
	}
}

// MARK: - - NSPopoverDelegate -
extension GenericPopover: NSPopoverDelegate{
	func detachableWindow(for popover: NSPopover) -> NSWindow? {
		return _window
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
	
	func popoverDidClose(_ notification: Notification) {
		_popover = nil
	}
}
