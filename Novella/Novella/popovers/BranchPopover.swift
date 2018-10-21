//
//  BranchPopover.swift
//  novella
//
//  Created by Daniel Green on 07/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class BranchPopover: GenericPopover {
	func setup(branch: NVBranch) {
		(_popoverViewController as? BranchViewController)?.Branch = branch
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "BranchPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
