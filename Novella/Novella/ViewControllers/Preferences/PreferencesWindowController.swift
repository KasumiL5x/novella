//
//  PreferencesWindowController.swift
//  Novella
//
//  Created by Daniel Green on 18/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	func windowShouldClose(_ sender: NSWindow) -> Bool {
		// hide window instead of close
		self.window?.orderOut(sender)
		return false
	}
}
