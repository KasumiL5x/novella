//
//  SwitchPopover.swift
//  Novella
//
//  Created by Daniel Green on 02/08/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class SwitchPopover: GenericPopover {
	func setup(swtch: NVSwitch) {
		(_popoverViewController as? SwitchPopoverViewController)?.setSwitch(swtch: swtch)
		(_detachedViewController as? SwitchPopoverViewController)?.setSwitch(swtch: swtch)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Switch")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
