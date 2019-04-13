//
//  SequenceLinkPopover.swift
//  novella
//
//  Created by Daniel Green on 10/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class LinkPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Link") as? LinkPopoverViewController
	}
	
	func setup(link: CanvasLink, doc: Document) {
		(ViewController as? LinkPopoverViewController)?.setup(link: link, doc: doc)
	}
}
