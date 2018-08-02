//
//  GenericPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class GenericPopoverWindow: NSWindow {
	override var canBecomeKey: Bool {
		return true
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
}

class GenericPopover: NSObject {
	// MARK: - Variables -
	private var _view: NSView?
	private var _popover: NSPopover?
	private var _window: GenericPopoverWindow?
	
	var _popoverViewController: NSViewController?
	var _detachedViewController: NSViewController?
	
	// MARK: - Properties -
	public var Detachable: Bool = true
	
	// MARK: - Initialization -
	override init() {
		self._view = nil
		self._popover = nil
		self._popoverViewController = nil
		self._detachedViewController = nil
		self._window = nil
		
		super.init()
	}
	
	func show(forView: NSView, at: NSRectEdge) {
		// reset everything if the view changed
		if _view != forView {
			_view = forView
			_popoverViewController = nil
			_detachedViewController = nil
			_window = nil
			_popover = nil
		}
		
		// create separate view controllers for popover and detached window
		if _popoverViewController == nil {
			_popoverViewController = createViewController()
		}
		if _detachedViewController == nil {
			_detachedViewController = createViewController()
		}
		if _popoverViewController == nil || _detachedViewController == nil {
			print("Attempted to create a NSViewController for a GenericPopover but was unable to do so.")
			return
		}
		
		// make and configure popover
		if _popover == nil {
			_popover = NSPopover()
			_popover!.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
			_popover!.animates = true
			_popover!.behavior = .transient
			_popover!.delegate = self
			_popover!.contentViewController = _popoverViewController
		}
		
		// make and configure window
		if _window == nil {
			let frame = _detachedViewController!.view.bounds
			let styleMask = NSWindow.StyleMask(rawValue: NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.closable.rawValue)
			let rect = NSWindow.contentRect(forFrameRect: frame, styleMask: styleMask)
			_window = GenericPopoverWindow(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: true)
			_window!.contentViewController = _detachedViewController
			_window!.isReleasedWhenClosed = false
			_window!.hidesOnDeactivate = true
			_window!.level = .floating
		}
		
		// show existing window or present inital popover
		if _window!.isVisible {
			_window!.close()
			_window!.makeKeyAndOrderFront(self)
		} else {
			_popover!.show(relativeTo: _view!.bounds, of: _view!, preferredEdge: at)
		}
	}
	
	// MARK: - - Virtual Functions -
	func createViewController() -> NSViewController? {
		print("GenericPopover::createViewController should be overridden.")
		return nil
	}
}

// MARK: - - NSPopoverDelegate -
extension GenericPopover: NSPopoverDelegate {
	func detachableWindow(for popover: NSPopover) -> NSWindow? {
		// this is requested when the window is detached.
		// setting the popover window's first responder to nil ensures that any in-progress edits are committed (if the user didn't tab or press return etc.).
		// we can't do this in popoverWill/DidClose as that's too late and window already exists.
		_popoverViewController?.view.window?.makeFirstResponder(nil)
		return _window
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return Detachable
	}
	
	func popoverDidClose(_ notification: Notification) {
		_popover = nil
	}
}
