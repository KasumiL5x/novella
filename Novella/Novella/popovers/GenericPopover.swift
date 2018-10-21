//
//  GenericPopover.swift
//  novella
//
//  Created by dgreen on 12/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class GenericPopoverWindow: NSWindow {
	override var canBecomeKey: Bool {
		return true
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
}

class GenericPopover: NSObject {
	// MARK: - Variables
	private var _popover: NSPopover? = nil
//	private var _window: GenericPopoverWindow? = nil
	var _popoverViewController: NSViewController? = nil
	
	// MARK: - Properties
	var Detachable: Bool {
		return true
	}
	
	// MARK: - Initialization
	override init() {
		super.init()
		createEverythingIfNeeded()
	}
	
	// MARK: - Functions
	@discardableResult private func createEverythingIfNeeded() -> Bool {
		// create view controllers for popover
		if _popoverViewController == nil {
			_popoverViewController = createViewController()
		}
		if _popoverViewController == nil {
			print("GenericPopover::createEverythingIfNeeded attempted to create an NSViewController but something went wrong.")
			return false
		}
		
		// make and configure popover
		if _popover == nil {
			_popover = NSPopover()
			_popover!.appearance = NSAppearance.init(named: NSAppearance.Name.aqua) // BUG: OutlineView elements will be colored by this unless overridden when not detached (i.e. light or dark will set their BG color; seems like a runtime bug).
			_popover!.animates = true
			_popover!.behavior = .transient
			_popover!.delegate = self
			_popover!.contentViewController = _popoverViewController
		}
		
		return true
	}
	
	func show(forView: NSView, at: NSRectEdge) {
		guard createEverythingIfNeeded() else {
			print("GenericPopover::show couldn't initialize correctly.")
			return
		}
		
		// show existing window or present inital popover
//		if let wnd = _window, wnd.isVisible {
//			wnd.close()
//			wnd.makeKeyAndOrderFront(self)
//		} else {
			_popover!.show(relativeTo: forView.bounds, of: forView, preferredEdge: at)
//		}
	}
	
	// MARK: - Virtuals
	func createViewController() -> NSViewController? {
		print("GenericPopover::createViewController should be overridden.")
		return nil
	}
}

// MARK: - NSPopoverDelegate -
extension GenericPopover: NSPopoverDelegate {
	func detachableWindow(for popover: NSPopover) -> NSWindow? {
		// The official docs (https://developer.apple.com/documentation/appkit/nspopoverdelegate/1534822-detachablewindow) say to
		// not remove the controller from the popover as it may exist at the same time as the window. It suggests making separate VCs
		// which means duplicating the content. I had this before but it's a pain in the ass to manage and they don't maintain states,
		// so i'm just going to use the default instead.
		return nil
		
//		// this is requested when the window is detached.
//		// setting the popover window's first responder to nil ensures that any in-progress edits are committed (if the user didn't tab or press return etc.).
//		// we can't do this in popoverWill/DidClose as that's too late and window already exists.
//		_popoverViewController?.view.window?.makeFirstResponder(nil)
//
//		// remove vc from the popover (not certain this is necessary but we're going to reassign it to the window)
//		_popover?.contentViewController = nil
//
//		// make and configure window if necessary
//		if _window == nil {
//			_window = GenericPopoverWindow(contentViewController: _popoverViewController!)
//			_window?.setContentSize(_popoverViewController!.view.frame.size)
//			_window!.isReleasedWhenClosed = false
//			_window!.hidesOnDeactivate = true
//			_window!.level = .floating
//		}
//		return _window
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return Detachable
	}
	
	func popoverDidClose(_ notification: Notification) {
		_popover = nil
	}
}
