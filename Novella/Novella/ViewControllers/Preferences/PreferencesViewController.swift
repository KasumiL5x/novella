//
//  PreferencesViewController.swift
//  Novella
//
//  Created by Daniel Green on 18/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		self.parent?.view.window?.title = self.title != nil ? self.title! : ""
	}
}
