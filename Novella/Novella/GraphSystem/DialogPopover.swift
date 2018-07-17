//
//  DialogPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DialogPopover: GenericPopover {
	func setup(node: DialogNode, manager: NVStoryManager) {
		(_popoverViewController as? DialogPopoverViewController)?.setDialogNode(node: node, manager: manager)
		(_detachedViewController as? DialogPopoverViewController)?.setDialogNode(node: node, manager: manager)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Dialog")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
