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
	
	// MARK: - Initialization -
	init(link: NVLink, owner: Node) {
		self._bgLayer = CAShapeLayer()
		self._transfer = nil
		self._graphMenu = NSMenu()
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
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinLink::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	// MARK: Virtuals
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
	
	// MARK: Graph Menu Callback
	@objc private func onGraphMenu(sender: NSMenuItem) {
		Owner._graphView.Undo.execute(cmd: SetTransferDestinationCmd(transfer: _transfer!, dest: sender.representedObject as? NVObject))
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		_bgLayer.fillColor = nil
		_bgLayer.strokeColor = NSColor.fromHex("#2D2D2D").cgColor
		let path = NSBezierPath(roundedRect: bounds, xRadius: PinLink.RADIUS, yRadius: PinLink.RADIUS)
		_bgLayer.path = path.cgPath
	}
}
