//
//  DeliveryPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class DeliveryPopover: GenericPopover {
	func setup(node: DeliveryNode) {
		(_popoverViewController as? DeliveryPopoverViewController)?.setDeliveryNode(node: node)
		(_detachedViewController as? DeliveryPopoverViewController)?.setDeliveryNode(node: node)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Delivery")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
