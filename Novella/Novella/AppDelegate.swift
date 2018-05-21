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
		Settings.loadDefaults()
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
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
	
	
	@IBAction func onFileNew(_ sender: Any) {
		(NSApplication.shared.mainWindow?.contentViewController as? MainViewController)?.onNew()
	}
	@IBAction func onFileOpen(_ sender: Any) {
		(NSApplication.shared.mainWindow?.contentViewController as? MainViewController)?.onOpen()
	}
	@IBAction func onFileClose(_ sender: Any) {
		(NSApplication.shared.mainWindow?.contentViewController as? MainViewController)?.onClose()
	}
	@IBAction func onFileSave(_ sender: Any) {
		(NSApplication.shared.mainWindow?.contentViewController as? MainViewController)?.onSave(forcePrompt: false)
	}
	@IBAction func onFileSaveAs(_ sender: Any) {
		(NSApplication.shared.mainWindow?.contentViewController as? MainViewController)?.onSave(forcePrompt: true)
	}
}

