//
//  DialogPopover.swift
//  novella
//
//  Created by Daniel Green on 06/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class DialogPopover: GenericPopover {
	func setup(doc: Document, dlg: NVDialog) {
		(_popoverViewController as? DialogViewController)?.Doc = doc
		(_popoverViewController as? DialogViewController)?.Dialog = dlg
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "ContentPopovers", bundle: nil)
		let popoverID = "DialogPopover"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
