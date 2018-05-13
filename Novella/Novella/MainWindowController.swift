//
//  MainWindowController.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
		
		// style toolbar and window
		window?.styleMask.remove(.unifiedTitleAndToolbar)
		window?.styleMask.remove(.fullSizeContentView)
		window?.styleMask.insert(.titled)
		window?.toolbar?.isVisible = true
		window?.titleVisibility = .hidden
		window?.titlebarAppearsTransparent = false
	}
	
	@IBAction func onToolbarNew(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.onNew()
	}
	
	@IBAction func onToolbarOpen(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.onOpen()
	}
	
	@IBAction func onToolbarSave(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.onSave()
	}
	
	@IBAction func onToolbarClose(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.onClose()
	}
}
