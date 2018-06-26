//
//  EntityTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class EntityTabViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _tableView: NSTableView!
	@IBOutlet private weak var _nameLabel: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - Interface Callbacks -
	@IBAction func onAddEntity(_ sender: NSButton) {
		print("Add entity.")
	}
	
	@IBAction func onRemoveEntity(_ sender: NSButton) {
		print("Remove entity.")
	}
}
