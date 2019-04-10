//
//  CanvasEventLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasEventLink: CanvasLink {
	let EventLink: NVEventLink
	let _popover: EventLinkPopover
	
	init(canvas: Canvas, origin: CanvasObject, link: NVEventLink) {
		self.EventLink = link
		self._popover = EventLinkPopover()
		super.init(canvas: canvas, origin: origin)
		
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasEventLink.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasEventLink.onDelete), keyEquivalent: "")
		
		// handle case where destination already exists
		if let dest = link.Destination, let destObj = canvas.canvasEventFor(nvEvent: dest) {
			setTarget(destObj)
		}
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onEdit() {
		_popover.show(forView: self, at: .maxX)
		_popover.setup(link: self, doc: _canvas.Doc)
	}
	
	@objc private func onDelete() {
		if Alerts.okCancel(msg: "Delete Link?", info: "Are you sure you want to delete this link? This action cannot be undone.", style: .critical) {
			_canvas.Doc.Story.delete(eventLink: self.EventLink)
		}
	}
	
	// virtuals
	override func canlinkTo(obj: CanvasObject) -> Bool {
		return (obj is CanvasEvent) && !(obj as! CanvasEvent).Event.Parallel
	}
	
	override func connectTo(obj: CanvasObject?) {
		// revert old CanvasEvent back to normal state and remove self as delegate
		if let oldDest = EventLink.Destination, let oldObj = _canvas.canvasEventFor(nvEvent: oldDest) {
			oldObj.CurrentState = .normal
			oldObj.remove(delegate: self)
		}
		
		// update model link destination
		EventLink.Destination = (obj as? CanvasEvent)?.Event ?? nil
		
		// add self as delegate
		obj?.add(delegate: self)
	}
}

extension CanvasEventLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		updateCurveTo(obj: obj)
	}
}
