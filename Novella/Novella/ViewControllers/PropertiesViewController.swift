//
//  PropertiesViewController.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class PropertiesViewController: NSViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.addTextField), name: NSNotification.Name(rawValue: "addTextField"), object: nil)
	}
	
	@objc func addTextField(notification: NSNotification) {
		print(notification.userInfo)
	}
}
