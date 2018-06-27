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
	// MARK: - Outlets -
	@IBOutlet private weak var _speakerButton: NSButton!
	@IBOutlet private weak var _nameTextField: NSTextField!
	@IBOutlet private weak var _directionsTextField: NSTextField!
	@IBOutlet private weak var _previewTextField: NSTextField!
	@IBOutlet private weak var _contentTextField: NSTextField!
	
	// MARK: - Variables -
	private var _dialogNode: DialogLinkableView?
	private var _manager: NVStoryManager?
	private var _speakerMenu: NSMenu?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		_dialogNode = nil
		_manager = nil
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	func setDialogNode(node: DialogLinkableView, manager: NVStoryManager) {
		_dialogNode = node
		_manager = manager
		
		let dlg = (_dialogNode!.Linkable as! NVDialog)
		
		let name = dlg.Name
		_nameTextField.stringValue = name.isEmpty ? "" : name
		
		let dirs = dlg.Directions
		_directionsTextField.stringValue = dirs.isEmpty ? "" : dirs
		
		let prev = dlg.Preview
		_previewTextField.stringValue = prev.isEmpty ? "" : prev
		
		let content = dlg.Content
		_contentTextField.stringValue = content.isEmpty ? "" : content
		
		_speakerMenu = NSMenu()
		for idx in 0..<manager.Entities.count {
			let entity = manager.Entities[idx]
			let item = NSMenuItem(title: entity.Name, action: #selector(DialogPopoverViewController.onSpeakerMenuSelected), keyEquivalent: "")
			item.tag = idx
			_speakerMenu?.addItem(item)
		}
	}
	
	// MARK: Menu Callbacks
	@objc private func onSpeakerMenuSelected() {
		guard let speakerMenuItem = _speakerMenu!.highlightedItem else {
			return
		}
		
		let speakerEntity = _manager!.Entities[speakerMenuItem.tag]
		(_dialogNode!.Linkable as! NVDialog).Speaker = speakerEntity
	}
	
	// MARK: Interface Callbacks
	@IBAction func onSpeakerClicked(_ sender: NSButton) {
		NSMenu.popUpContextMenu(_speakerMenu!, with: NSApp.currentEvent!, for: _speakerButton)
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
