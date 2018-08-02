//
//  PinSwitch.swift
//  Novella
//
//  Created by Daniel Green on 31/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinSwitch: Pin {
	// MARK: - Statics -
	static let RADIUS: CGFloat = 6.0
	static let PADDING: CGFloat = 2.0
	static let SPACING: CGFloat = 3.0
	
	// MARK: - Variables -
	private var _bgLayer: CAShapeLayer
	private let _contextMenu: NSMenu
	private var _defaultTransfer: Transfer?
	private let _switchPopover: SwitchPopover

	// MARK: - Initialization -
	init(swtch: NVSwitch, owner: Node) {
		self._bgLayer = CAShapeLayer()
		self._contextMenu = NSMenu()
		self._defaultTransfer = nil
		self._switchPopover = SwitchPopover()
		self._switchPopover.Detachable = false
		super.init(link: swtch, owner: owner)
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_bgLayer)
		
		// todo:
		//   - add some popover for switch variable setting
		//   - implement list of switches (test with fake options)
		//   - implement adding of options for this and in the model
		//   - when options are added or removed, somehow i need the node to layout everything.
		//   - implement right click for the various options.
		//   - type restrictions for the option popover should be set by the variable type.r
		
		// context menu
		_contextMenu.addItem(withTitle: "Choose Variable", action: #selector(PinSwitch.onContextChooseVariable), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Add Option", action: nil, keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Remove Option", action: nil, keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Edit Option Value", action: nil, keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Edit Option Function", action: nil, keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Edit Precondition", action: nil, keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Trash", action: nil, keyEquivalent: "")
		
		// setup transfers
		self._defaultTransfer = Transfer(transfer: swtch.DefaultTransfer, owner: self)
		self.addSubview(_defaultTransfer!)
		
		// layout the transfers
		layoutTransfers()
		
		// calculate bounds including padding
		var subFrame = subviewsFrame()
		subFrame.width += PinSwitch.PADDING
		subFrame.height += PinSwitch.PADDING
		self.frame.size = subFrame
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinSwitch::init(coder) not implemented.")
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
	private func layoutTransfers() {
		// default transfer at the bottom
		_defaultTransfer?.frame.origin += NSMakePoint(PinSwitch.PADDING, PinSwitch.PADDING)
	}
	
	// MARK: Virtuals
	override func contextClicked(_ gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextChooseVariable() {
		_switchPopover.show(forView: self, at: .maxX)
		_switchPopover.setup(swtch: BaseLink as! NVSwitch)
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		_bgLayer.fillColor = nil
		_bgLayer.strokeColor = BaseLink.InTrash ? Settings.graph.trashedColorDark.cgColor :  NSColor.fromHex("#4a4a4a").cgColor
		let path = NSBezierPath(roundedRect: bounds, xRadius: PinSwitch.RADIUS, yRadius: PinSwitch.RADIUS)
		_bgLayer.path = path.cgPath
	}
}
