//
//  VariablePopover.swift
//  novella
//
//  Created by dgreen on 13/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class VariablePopover: GenericPopover {
	func setup(doc: Document) {
		(_popoverViewController as? VariablesViewController)?.Doc = doc
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "Variables", bundle: nil)
		let popoverID = "Variables"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
