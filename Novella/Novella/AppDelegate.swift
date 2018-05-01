//
//  AppDelegate.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if #available(OSX 10.12.2, *) {
			NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
		}
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
	}
}

