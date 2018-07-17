//
//  ContextPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ContextPopover: GenericPopover {
	func setup(node: ContextNode) {
		(_popoverViewController as? ContextPopoverViewController)?.setContextNode(node: node)
		(_detachedViewController as? ContextPopoverViewController)?.setContextNode(node: node)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Context")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
