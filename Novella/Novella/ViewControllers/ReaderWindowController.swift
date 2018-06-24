//
//  NewReaderWindowController.swift
//  Novella
//
//  Created by Daniel Green on 12/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ReaderWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	func setDocument(doc: NovellaDocument) {
		(contentViewController as? ReaderViewController)?._document = doc
	}
}
