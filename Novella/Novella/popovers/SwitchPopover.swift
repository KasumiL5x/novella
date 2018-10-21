//
//  SwitchPopover.swift
//  novella
//
//  Created by dgreen on 18/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class SwitchPopover: GenericPopover {
	override var Detachable: Bool {
		return false
	}
	
	func setup(story: NVStory, swtch: NVSwitch) {
		(_popoverViewController as? SwitchViewController)?.setup(story: story, swtch: swtch)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "SwitchPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
