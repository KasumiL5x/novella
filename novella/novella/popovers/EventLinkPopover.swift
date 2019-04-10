//
//  EventLinkPopover.swift
//  novella
//
//  Created by Daniel Green on 10/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class EventLinkPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "EventLink") as? EventLinkPopoverViewController
	}
	
	func setup(link: CanvasEventLink, doc: Document) {
		(ViewController as? EventLinkPopoverViewController)?.setup(link: link, doc: doc)
	}
}
