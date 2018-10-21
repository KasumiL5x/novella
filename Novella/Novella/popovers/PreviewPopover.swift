//
//  PreviewPopover.swift
//  novella
//
//  Created by dgreen on 13/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class PreviewPopover: GenericPopover {
	func setup(doc: Document, graph: NVGraph) {
		(_popoverViewController as? PreviewViewController)?.Doc = doc
		(_popoverViewController as? PreviewViewController)?.Graph = graph
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: "Preview", bundle: nil)
		let popoverID = "Preview"
		return popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
	}
}
