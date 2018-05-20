//
//  NodePopover.swift
//  Novella
//
//  Created by Daniel Green on 20/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class NodePopover: NSObject, NSPopoverDelegate {
	// MARK: - - Variables -
	fileprivate var _node: LinkableView?
	fileprivate var _popover: NSPopover?
	fileprivate var _viewController: NSViewController?
	fileprivate var _window: NSWindow?
	
	// MARK: - - Initialization -
	override init() {
		self._node = nil
		self._popover = nil
		self._viewController = nil
		self._window = nil
		
		super.init()
	}
	
	// MARK: - - Properties -
	var Node: LinkableView? {
		get{ return _node }
	}
	var ViewController: NSViewController? {
		get{ return _viewController }
	}
	
	// MARK: - - Functions -
	func show(forView: LinkableView, at: NSRectEdge) {
		// store node and create everything if needed
		_node = forView
		create()
		
		// show existing window or present inital popover
		if _window!.isVisible {
			_window!.makeKeyAndOrderFront(self)
		} else {
			_popover!.show(relativeTo: _node!.bounds, of: _node!, preferredEdge: at)
		}
	}
	
	fileprivate func create() {
		// view controller
		if _viewController == nil {
			let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
			let popoverID: NSStoryboard.SceneIdentifier
			switch _node {
			case is DialogLinkableView:
				popoverID = NSStoryboard.SceneIdentifier(rawValue: "GraphDialogPopover")
			default:
				fatalError("NodePopover::createViewController() encountered an unexpected node type (\(_node!)).")
			}
			_viewController = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		}
		
		// window
		if _window == nil {
			let frame = _viewController!.view.bounds
			let styleMask = NSWindow.StyleMask(rawValue: NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.closable.rawValue)
			let rect = NSWindow.contentRect(forFrameRect: frame, styleMask: styleMask)
			self._window = NSWindow(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: true)
			self._window!.contentViewController = _viewController!
			self._window!.isReleasedWhenClosed = false
			self._window!.hidesOnDeactivate = true
			self._window!.level = .floating
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
	}
	
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
