//
//  SwitchPopover.swift
//  Novella
//
//  Created by Daniel Green on 01/08/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class SwitchOptionPopover: GenericPopover {
	func setup(variable: NVVariable) {
		(_popoverViewController as? SwitchOptionPopoverViewController)?.setVariable(variable: variable)
		(_detachedViewController as? SwitchOptionPopoverViewController)?.setVariable(variable: variable)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "SwitchOption")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
