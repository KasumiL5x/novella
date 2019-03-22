//
//  AppDelegate.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}
	
	@IBAction func onExportJSON(_ sender: NSMenuItem) {
		let viewController = NSApplication.shared.mainWindow?.contentViewController as? MainViewController
		viewController?.exportJSON()
	}
}

