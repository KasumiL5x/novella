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
		_nameTextField.stringValue = name.isEmpty ? "" : name
		
		let dirs = dlg.Preview
		_directionsTextField.stringValue = dirs.isEmpty ? "" : dirs
		
		let prev = dlg.Preview
		_previewTextField.stringValue = prev.isEmpty ? "" : prev
		
		let content = dlg.Content
		_contentTextField.stringValue = content.isEmpty ? "" : content
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		if _dialogNode == nil {
			return
		}
		
		let oldName = (_dialogNode!.Linkable as! NVDialog).Name
		let newName = sender.stringValue
		
		// don't forget to revert sender if name change fails
		
		print("Name changed from \(oldName) to \(newName) (but not implemented yet)")
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		if _dialogNode == nil {
			return
		}
		
		let oldDir = (_dialogNode!.Linkable as! NVDialog).Directions
		let newDir = sender.stringValue
		
		print("Directions changed from \(oldDir) to \(newDir) (but not implemented yet)")
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		if _dialogNode == nil {
			return
		}
		
		let oldPrev = (_dialogNode!.Linkable as! NVDialog).Preview
		let newPrev = sender.stringValue
		
		print("Preview changed from \(oldPrev) to \(newPrev) (but not implemented yet)")
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		if _dialogNode == nil {
			return
		}
		
		let oldContent = (_dialogNode!.Linkable as! NVDialog).Content
		let newContent = sender.stringValue
		
		print("Content changed from \(oldContent) to \(newContent) (but not implemented yet)")
	}
	
	
	
	
}
