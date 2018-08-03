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
	private var _options: [(transfer: Transfer, opt: NVSwitchOption)]
	private let _switchPopover: SwitchPopover
	private let _conditionPopover: ConditionPopover

	// MARK: - Initialization -
	init(swtch: NVSwitch, owner: Node) {
		self._bgLayer = CAShapeLayer()
		self._contextMenu = NSMenu()
		self._defaultTransfer = nil
		self._options = []
		self._switchPopover = SwitchPopover()
		self._switchPopover.Detachable = false
		self._conditionPopover = ConditionPopover()
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
		_contextMenu.addItem(withTitle: "Add Option", action: #selector(PinSwitch.onContextAddOption), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Remove Option", action: #selector(PinSwitch.onContextRemoveOption), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Edit Option Value", action: #selector(PinSwitch.onContextEditOptionValue), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Edit Option Function", action: #selector(PinSwitch.onContextEditOptionFunction), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Edit Precondition", action: #selector(PinSwitch.onContextEditPreCondition), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Trash", action: nil, keyEquivalent: "")
		
		// setup transfers
		self._defaultTransfer = Transfer(transfer: swtch.DefaultTransfer, owner: self)
		
		// layout the transfers
		layoutTransfers()
		// calculate bounds including padding
		setFrame()
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
		// remove all as we add them dynamically
		self.subviews.removeAll()
		
		// default transfer at the bottom
		self.addSubview(_defaultTransfer!)
		_defaultTransfer!.frame.origin = NSMakePoint(PinSwitch.PADDING, PinSwitch.PADDING)
		
		// create local transfers and switch options
		_options = []
		for opt in (BaseLink as! NVSwitch).Options {
			let entry = (transfer: Transfer(transfer: opt.Transfer, owner: self), opt: opt)
			_options.append(entry)
			self.addSubview(entry.transfer)
		}
		
		// all options above that with spacing
		var lastY = _defaultTransfer!.frame.maxY
		for opt in _options {
			opt.transfer.frame.origin.x = PinSwitch.PADDING
			opt.transfer.frame.origin.y = lastY + PinSwitch.PADDING
			
			lastY = opt.transfer.frame.maxY
		}
	}
	private func setFrame() {
		var subFrame = subviewsFrame()
		subFrame.width += PinSwitch.PADDING
		subFrame.height += PinSwitch.PADDING
		self.frame.size = subFrame
	}
	
	// MARK: Virtuals
	override func redraw() {
		setNeedsDisplay(bounds)
		_defaultTransfer?.redraw()
		_options.forEach{$0.transfer.redraw()}
	}
	override func contextClicked(_ gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextChooseVariable() {
		_switchPopover.show(forView: self, at: .maxX)
		_switchPopover.setup(swtch: BaseLink as! NVSwitch, doc: Owner._graphView.Document)
	}
	@objc private func onContextAddOption() {
		let _ = (BaseLink as! NVSwitch).addOption()
		layoutTransfers()
		setFrame()
		redraw()
		
		// TODO: Not sure I should be accessing like this - may make a single public function and make these private
		Owner.layoutBoard()
		Owner.sizeToFitSubviews()
		Owner.redraw()
	}
	@objc private func onContextRemoveOption() {
		fatalError("Not yet implemented.")
	}
	@objc private func onContextEditOptionValue() {
		fatalError("Not yet implemented.")
	}
	@objc private func onContextEditOptionFunction() {
		fatalError("Not yet implemented.")
	}
	@objc private func onContextEditPreCondition() {
		fatalError("I forgot to add preconditions to switches in the model... will do this later.")
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
