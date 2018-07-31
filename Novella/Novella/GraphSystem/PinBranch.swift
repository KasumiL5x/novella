//
//  PinBranch.swift
//  Novella
//
//  Created by Daniel Green on 30/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinBranch: Pin {
	// MARK: - Statics -
	static let PADDING: CGFloat = 2.0
	static let RADIUS: CGFloat = 6.0
	static let SPACING: CGFloat = 3.0
	
	// MARK: - Variables -
	private var _bgLayer: CAShapeLayer
	private var _trueTransfer: Transfer?
	private var _falseTransfer: Transfer?
	private var _pannedTransfer: Transfer?
	private var _graphMenu: NSMenu
	
	
	// MARK: - Initialization -
	init(branch: NVBranch, owner: Node) {
		self._bgLayer = CAShapeLayer()
		self._trueTransfer = nil
		self._falseTransfer = nil
		self._pannedTransfer = nil
		self._graphMenu = NSMenu()
		super.init(link: branch, owner: owner)
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_bgLayer)
		
		// init transfers (must be optional as self is used)
		self._trueTransfer = Transfer(transfer: branch.TrueTransfer, owner: self)
		self._falseTransfer = Transfer(transfer: branch.FalseTransfer, owner: self)
		self.addSubview(self._trueTransfer!)
		self.addSubview(self._falseTransfer!)
		
		// position top transfer
		self._trueTransfer!.frame.origin.y = _falseTransfer!.frame.maxY + PinBranch.SPACING
		// align transfers horizontally and offset vertically
		_trueTransfer!.frame.origin += NSMakePoint(PinBranch.PADDING, PinBranch.PADDING)
		_falseTransfer!.frame.origin += NSMakePoint(PinBranch.PADDING, PinBranch.PADDING)
		
		// calculate bounds including padding
		var subFrame = subviewsFrame()
		subFrame.width += PinBranch.PADDING
		subFrame.height += PinBranch.PADDING
		self.frame.size = subFrame
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinBranch::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
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
	func transferAt(_ point: CGPoint) -> Transfer? {
		if NSPointInRect(point, _trueTransfer!.frame) {
			return _trueTransfer
		}
		if NSPointInRect(point, _falseTransfer!.frame) {
			return _falseTransfer
		}
		return nil
	}
	
	// MARK: Virtual
	override func panStarted(_ gesture: NSPanGestureRecognizer) {
		_pannedTransfer = transferAt(gesture.location(in: self))
		if let transfer = _pannedTransfer {
			transfer.IsDragging = true
			transfer.DragPosition = gesture.location(in: transfer)
		}
	}
	override func panChanged(_ gesture: NSPanGestureRecognizer) {
		if let transfer = _pannedTransfer {
			transfer.DragPosition = gesture.location(in: transfer)
		}
	}
	override func panEnded(_ gesture: NSPanGestureRecognizer) {
		if let transfer = _pannedTransfer {
			_pannedTransfer?.IsDragging = false
			
			switch Target {
			case is GraphNode:
				_graphMenu.removeAllItems()
				let asGraph = (Target?.Object as! NVGraph)
				for child in asGraph.Nodes {
					let menuItem = NSMenuItem(title: (child.Name.isEmpty ? "Unnamed" : child.Name), action: #selector(PinBranch.onGraphMenu), keyEquivalent: "")
					menuItem.target = self
					menuItem.representedObject = child
					_graphMenu.addItem(menuItem)
				}
				NSMenu.popUpContextMenu(_graphMenu, with: NSApp.currentEvent!, for: Target!)
				
			default:
				Owner._graphView.Undo.execute(cmd: SetTransferDestinationCmd(transfer: transfer, dest: Target?.Object))
			}
		}
		
		_pannedTransfer = nil
	}
	
	// MARK: Graph Menu Callback
	@objc private func onGraphMenu(sender: NSMenuItem) {
		// NOTE: This works because menus are BLOCKING. _pannedTransfer won't be set to nil until this function is called.
		Owner._graphView.Undo.execute(cmd: SetTransferDestinationCmd(transfer: _pannedTransfer!, dest: sender.representedObject as? NVObject))
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		_bgLayer.fillColor = nil
		_bgLayer.strokeColor = NSColor.fromHex("#2D2D2D").cgColor
		let path = NSBezierPath(roundedRect: bounds, xRadius: PinBranch.RADIUS, yRadius: PinBranch.RADIUS)
		_bgLayer.path = path.cgPath
	}
}
