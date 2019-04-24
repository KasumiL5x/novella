//
//  ReturnPopover.swift
//  novella
//
//  Created by Daniel Green on 24/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class ReturnPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Return") as? ReturnPopoverViewController
	}
	
	func setup(rtrn: CanvasReturn, doc: Document) {
		(ViewController as? ReturnPopoverViewController)?.setup(rtrn: rtrn, doc: doc)
	}
}
