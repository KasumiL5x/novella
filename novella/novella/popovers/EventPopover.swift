//
//  EventPopover.swift
//  novella
//
//  Created by Daniel Green on 09/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class EventPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Event") as? EventPopoverViewController
	}
	
	func setup(event: CanvasEvent, doc: Document) {
		(ViewController as? EventPopoverViewController)?.setup(event: event, doc: doc)
	}
}
