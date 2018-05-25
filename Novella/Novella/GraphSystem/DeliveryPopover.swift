//
//  DeliveryPopover.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class DeliveryPopover: GenericPopover {
	override func createViewController() -> Bool {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Delivery")
		_viewController = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return _viewController != nil
	}
}
