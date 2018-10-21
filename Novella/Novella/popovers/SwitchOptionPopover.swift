//
//  SwitchOptionPopover.swift
//  novella
//
//  Created by dgreen on 18/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class SwitchOptionPopover: GenericPopover {
	override var Detachable: Bool {
		return false
	}
	
	func setup(option: NVSwitchOption) {
		(_popoverViewController as? SwitchOptionViewController)?.setup(option: option)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "SwitchOptionPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
