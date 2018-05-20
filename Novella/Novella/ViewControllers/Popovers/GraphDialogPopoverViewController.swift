//
//  GraphDialogPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 19/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphDialogPopoverViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _nameTextField: NSTextField!
	@IBOutlet fileprivate weak var _directionsTextField: NSTextField!
	@IBOutlet fileprivate weak var _previewTextField: NSTextField!
	@IBOutlet weak var _contentTextField: NSTextField!
	
	// MARK: - - Variables -
	fileprivate var _dialogNode: DialogLinkableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_dialogNode = nil
		
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	func setDialogNode(node: DialogLinkableView!) {
		_dialogNode = node
		
		let dlg = (_dialogNode!.Linkable as! NVDialog)
		
		let name = dlg.Name
		_nameTextField.stringValue = name.isEmpty ? "No name" : name
		
		let dirs = dlg.Preview
		_directionsTextField.stringValue = dirs.isEmpty ? "No directions" : dirs
		
		let prev = dlg.Preview
		_previewTextField.stringValue = prev.isEmpty ? "No preview" : prev
		
		let content = dlg.Content
		_contentTextField.stringValue = content.isEmpty ? "No content" : content
	}
}
