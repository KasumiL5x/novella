//
//  SequenceLinkPopover.swift
//  novella
//
//  Created by Daniel Green on 10/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class SequenceLinkPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "SequenceLink") as? SequenceLinkPopoverViewController
	}
	
	func setup(link: CanvasSequenceLink, doc: Document) {
		(ViewController as? SequenceLinkPopoverViewController)?.setup(link: link, doc: doc)
	}
}
