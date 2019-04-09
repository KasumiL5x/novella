//
//  SequencePopover.swift
//  novella
//
//  Created by Daniel Green on 09/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class SequencePopover: Popover {
	override func createViewController() -> NSViewController? {
		let sb = NSStoryboard(name: "Popovers", bundle: nil)
		return sb.instantiateController(withIdentifier: "Sequence") as? SequencePopoverViewController
	}
	
	func setup(sequence: CanvasSequence, doc: Document) {
		(ViewController as? SequencePopoverViewController)?.setup(sequence: sequence, doc: doc)
	}
}
