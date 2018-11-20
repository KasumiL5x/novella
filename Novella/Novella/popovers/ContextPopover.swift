//
//  ContextPopover.swift
//  novella
//
//  Created by Daniel Green on 20/11/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class ContextPopover: GenericPopover {
	func setup(ctx: NVContext) {
		(_popoverViewController as? ContextPopoverViewController)?.Context = ctx
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "ContextPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
