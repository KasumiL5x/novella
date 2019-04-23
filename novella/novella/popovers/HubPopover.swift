//
//  HubPopover.swift
//  novella
//
//  Created by Daniel Green on 23/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class HubPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Hub") as? HubPopoverViewController
	}
	
	func setup(hub: CanvasHub, doc: Document) {
		(ViewController as? HubPopoverViewController)?.setup(hub: hub, doc: doc)
	}
}
