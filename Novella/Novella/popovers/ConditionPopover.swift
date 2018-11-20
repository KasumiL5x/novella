//
//  ConditionPopover.swift
//  novella
//
//  Created by Daniel Green on 21/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class ConditionPopover: GenericPopover {
	func setup(condition: NVCondition) {
		(_popoverViewController as? ConditionViewController)?.Condition = condition
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "ConditionPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
