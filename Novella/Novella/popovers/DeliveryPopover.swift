//
//  DeliveryPopover.swift
//  novella
//
//  Created by dgreen on 14/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class DeliveryPopover: GenericPopover {
	func setup(doc: Document, delivery: NVDelivery) {
		(_popoverViewController as? DeliveryViewController)?.Doc = doc
		(_popoverViewController as? DeliveryViewController)?.Delivery = delivery
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "DeliveryPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
