//
//  Link.swift
//  novella
//
//  Created by Daniel Green on 14/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class Link: NSView {
	// MARK: - Variables
	private var _canvas: Canvas
	private var _bgLayer = CAShapeLayer()
	private var _conditionPopover = ConditionPopover()
	
	// MARK: - Properties
	private(set) var TheLink: NVLink
	private(set) var TheTransfer: Transfer?
	
	// MARK: - Initialization
	init(canvas: Canvas, link: NVLink) {
		self._canvas = canvas
		self.TheLink = link
		super.init(frame: NSMakeRect(0, 0, 1, 1))
		
		// setup backing layer
		wantsLayer = true
		layer!.masksToBounds = false
		layer!.addSublayer(_bgLayer)
		
		// setup transfer
		TheTransfer = Transfer(size: 15.0, transfer: link.Transfer, canvas: canvas)
		addSubview(TheTransfer!)
		
		// position transfer and expand frame to fit transfer including padding
		let padding: CGFloat = 2.0
		TheTransfer!.frame.origin = NSMakePoint(padding, padding)
		frame.size = NSMakeSize(TheTransfer!.frame.origin.x + TheTransfer!.frame.width + padding, TheTransfer!.frame.origin.y + TheTransfer!.frame.height + padding)
		
		// add link menu items to the transfer
		TheTransfer!.Menu.addItem(withTitle: "Edit Precondition", action: #selector(Link.onContextPrecondition), keyEquivalent: "")
		TheTransfer!.Menu.addItem(NSMenuItem.separator())
		TheTransfer!.Menu.addItem(withTitle: "Delete Link", action: #selector(Link.onContextDelete), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Link::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	func redraw() {
		TheTransfer?.redraw()
		setNeedsDisplay(bounds)
	}
	
	// MARK: Menu Callbacks
	@objc private func onContextPrecondition() {
		_conditionPopover.show(forView: self, at: .minY)
		_conditionPopover.setup(condition: TheLink.PreCondition)
	}
	@objc private func onContextDelete() {
		if Alerts.okCancel(msg: "Delete Link?", info: "Are you sure you want to delete this link? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.deleteLink(link: self.TheLink)
		}
	}

	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let roundness: CGFloat = 6.0
			_bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05).cgColor
			_bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: roundness, yRadius: roundness).cgPath
			
			context.restoreGState()
		}
		
	}
}
