//
//  DialogPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 19/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DialogPopoverViewController: NSViewController {
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
		_nameTextField.stringValue = name.isEmpty ? "" : name
		
		let dirs = dlg.Directions
		_directionsTextField.stringValue = dirs.isEmpty ? "" : dirs
		
		let prev = dlg.Preview
		_previewTextField.stringValue = prev.isEmpty ? "" : prev
		
		let content = dlg.Content
		_contentTextField.stringValue = content.isEmpty ? "" : content
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let dlg = _dialogNode?.Linkable as? NVDialog else {
			return
		}
		dlg.Name = sender.stringValue
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		guard let dlg = _dialogNode?.Linkable as? NVDialog else {
			return
		}
		dlg.Directions = sender.stringValue
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		guard let dlg = _dialogNode?.Linkable as? NVDialog else {
			return
		}
		dlg.Preview = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		guard let dlg = _dialogNode?.Linkable as? NVDialog else {
			return
		}
		dlg.Content = sender.stringValue
	}
}
