//
//  GroupPopover.swift
//  novella
//
//  Created by Daniel Green on 07/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class GroupPopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Group") as? GroupPopoverViewController
	}
	
	func setup(group: CanvasGroup, doc: Document) {
		(ViewController as? GroupPopoverViewController)?.setup(group: group, doc: doc)
	}
}
