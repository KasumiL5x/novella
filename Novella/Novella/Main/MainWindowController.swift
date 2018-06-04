//
//  MainWindowController.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	// MARK: - Toolbar Callbacks -
	@IBAction func onToolbarUndo(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.undo()
	}
	
	@IBAction func onToolbarRedo(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.redo()
	}
	
	@IBAction func onToolbarZoomSelected(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.zoomActiveGraph()
	}
	
	@IBAction func onToolbarVariableEditor(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.openVariableEditor()
	}
}
