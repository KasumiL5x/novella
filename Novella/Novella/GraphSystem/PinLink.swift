//
//  PinLink.swift
//  Novella
//
//  Created by Daniel Green on 30/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinLink: Pin {
	// MARK: - Statics -
	static let PADDING: CGFloat = 2.0
	static let RADIUS: CGFloat = 6.0
	
	// MARK: - Variables -
	private var _bgLayer: CAShapeLayer
	private var _transfer: Transfer?
	private let _graphMenu: NSMenu
	private let _contextMenu: NSMenu
	private let _deleteMenuItem: NSMenuItem
	private let _conditionPopover: ConditionPopover
	
	// MARK: - Initialization -
	init(link: NVLink, owner: Node) {
		self._bgLayer = CAShapeLayer()
		self._transfer = nil
		self._graphMenu = NSMenu()
		self._contextMenu = NSMenu()
		self._deleteMenuItem = NSMenuItem(title: "Trash", action: #selector(PinLink.onContextDelete), keyEquivalent: "")
		self._conditionPopover = ConditionPopover()
		super.init(link: link, owner: owner)
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_bgLayer)
		
		// transfer
		self._transfer = Transfer(transfer: link.Transfer, owner: self)
		self.addSubview(self._transfer!)
		
		// alignment
		self._transfer!.frame.origin += NSMakePoint(PinLink.PADDING, PinLink.PADDING)
		
		// size including padding
		var subFrame = NSMakeSize(_transfer!.frame.origin.x + _transfer!.frame.width, _transfer!.frame.origin.y + _transfer!.frame.height)
		subFrame.width += PinLink.PADDING
		subFrame.height += PinLink.PADDING
		self.frame.size = subFrame
		
		// context menu
		_contextMenu.addItem(withTitle: "Edit Function", action: #selector(PinLink.onContextFunction), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Edit PreCondition", action: #selector(PinLink.onContextPreCondition), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_deleteMenuItem)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinLink::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	// MARK: Virtuals
	override func redraw() {
		setNeedsDisplay(bounds)
		_transfer?.redraw()
	}
	override func panStarted(_ gesture: NSPanGestureRecognizer) {
		_transfer?.IsDragging = true
		_transfer?.DragPosition = gesture.location(in: _transfer)
	}
	override func panChanged(_ gesture: NSPanGestureRecognizer) {
		_transfer?.DragPosition = gesture.location(in: _transfer)
	}
	override func panEnded(_ gesture: NSPanGestureRecognizer) {
		_transfer?.IsDragging = false
		
		switch Target {
		case is GraphNode:
			_graphMenu.removeAllItems()
			let asGraph = (Target?.Object as! NVGraph)
			for child in asGraph.Nodes {
				let menuItem = NSMenuItem(title: (child.Name.isEmpty ? "Unnamed" : child.Name), action: #selector(PinLink.onGraphMenu), keyEquivalent: "")
				menuItem.target = self
				menuItem.representedObject = child
				_graphMenu.addItem(menuItem)
			}
			NSMenu.popUpContextMenu(_graphMenu, with: NSApp.currentEvent!, for: Target!)
				
		default:
			Owner._graphView.Undo.execute(cmd: SetTransferDestinationCmd(transfer: _transfer!, dest: Target?.Object))
		}
	}
	override func contextClicked(_ gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	override func trashed() {
		_deleteMenuItem.title = "Untrash"
	}
	override func untrashed() {
		_deleteMenuItem.title = "Trash"
	}
	
	// MARK: Graph Menu Callback
	@objc private func onGraphMenu(sender: NSMenuItem) {
		Owner._graphView.Undo.execute(cmd: SetTransferDestinationCmd(transfer: _transfer!, dest: sender.representedObject as? NVObject))
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextFunction() {
		_transfer?.showFunctionPopover()
	}
	@objc private func onContextPreCondition() {
		_conditionPopover.show(forView: self, at: .maxX)
		_conditionPopover.setup(condition: (BaseLink as! NVLink).PreCondition)
	}
	@objc private func onContextDelete() {
		BaseLink.InTrash ? BaseLink.untrash() : BaseLink.trash()
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		_bgLayer.fillColor = nil
		_bgLayer.strokeColor = BaseLink.InTrash ? Settings.graph.trashedColorDark.cgColor : NSColor.fromHex("#4a4a4a").cgColor
		let path = NSBezierPath(roundedRect: bounds, xRadius: PinLink.RADIUS, yRadius: PinLink.RADIUS)
		_bgLayer.path = path.cgPath
	}
}
