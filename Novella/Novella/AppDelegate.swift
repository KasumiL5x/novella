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
	fileprivate var _preferencesController: NSWindowController?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Settings.resetToApp()
		Settings.saveDefaults() // uncomment to force write of settings
		Settings.loadDefaults()
	}

	@IBAction func onPreferences(_ sender: NSMenuItem) {
		if nil == _preferencesController {
			let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
			_preferencesController = sb.instantiateInitialController() as? NSWindowController
		}
		
		if _preferencesController != nil {
			_preferencesController!.showWindow(sender)
		}
	}
	
	
}

