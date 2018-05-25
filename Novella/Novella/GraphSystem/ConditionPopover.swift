//
//  ConditionPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ConditionPopover: GenericPopover {
	override func createViewController() -> Bool {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Condition")
		_viewController = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return _viewController != nil
	}
}
