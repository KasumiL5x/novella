//
//  FunctionPopover.swift
//  novella
//
//  Created by Daniel Green on 21/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class FunctionPopover: GenericPopover {
	func setup(transfer: NVTransfer) {
		(_popoverViewController as? FunctionPopoverViewController)?.TheTransfer = transfer
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "FunctionPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
