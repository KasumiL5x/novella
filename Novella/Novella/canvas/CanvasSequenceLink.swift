//
//  CanvasSequenceLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasSequenceLink: CanvasLink {
	let SequenceLink: NVSequenceLink
	let _popover: SequenceLinkPopover
	
	init(canvas: Canvas, origin: CanvasObject, link: NVSequenceLink) {
		self.SequenceLink = link
		self._popover = SequenceLinkPopover()
		super.init(canvas: canvas, origin: origin)
		
		
		ContextMenu.addItem(withTitle: "Edit...", action: #selector(CanvasSequenceLink.onEdit), keyEquivalent: "")
		ContextMenu.addItem(NSMenuItem.separator())
		ContextMenu.addItem(withTitle: "Delete", action: #selector(CanvasSequenceLink.onDelete), keyEquivalent: "")
		
		// handle case where destination already exists
		if let dest = link.Destination, let destObj = canvas.canvasSequenceFor(nvSequence: dest) {
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
		print("Not yet Cap'n!")
	}
	
	// virtuals
	override func canlinkTo(obj: CanvasObject) -> Bool {
		return (obj is CanvasSequence) && !(obj as! CanvasSequence).Sequence.Parallel
	}
	
	override func connectTo(obj: CanvasObject?) {
		// revert old CanvasSequence back to normal state and remove self as delegate
		if let oldDest = SequenceLink.Destination, let oldObj = _canvas.canvasSequenceFor(nvSequence: oldDest) {
			oldObj.CurrentState = .normal
			oldObj.remove(delegate: self)
		}
		
		// update model link destination
		SequenceLink.Destination = (obj as? CanvasSequence)?.Sequence ?? nil
		
		// add self as delegate
		obj?.add(delegate: self)
	}
}

extension CanvasSequenceLink: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		updateCurveTo(obj: obj)
	}
}
