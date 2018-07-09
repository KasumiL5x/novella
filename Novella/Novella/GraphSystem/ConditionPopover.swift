//
//  ConditionPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class ConditionPopover: GenericPopover {
	func setup(condition: NVCondition) {
		(_popoverViewController as? ConditionPopoverViewController)?.setCondition(condition: condition)
		(_detachedViewController as? ConditionPopoverViewController)?.setCondition(condition: condition)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Condition")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
