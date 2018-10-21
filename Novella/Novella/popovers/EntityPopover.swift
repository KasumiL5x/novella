//
//  EntityPopover.swift
//  novella
//
//  Created by dgreen on 12/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class EntityPopover: GenericPopover {
	func setup(doc: Document) {
		(_popoverViewController as? EntitiesViewController)?.Doc = doc
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "Entities", bundle: nil)
		let popoverID = "Entities"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
