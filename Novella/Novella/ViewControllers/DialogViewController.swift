//
//  DialogViewController.swift
//  novella
//
//  Created by Daniel Green on 06/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class DialogViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _instigatorImgBtn: NSButton!
	@IBOutlet weak var _idTextfield: NSTextField!
	@IBOutlet weak var _directionsTextfield: NSTextField!
	@IBOutlet weak var _previewTextfield: NSTextField!
	@IBOutlet weak var _contentTextfield: NSTextField!
	
	// MARK: - Variables
	private var _instigatorMenu: NSMenu?
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			refreshContent()
		}
	}
	var Dialog: NVDialog? {
		didSet {
			refreshContent()
		}
	}
	
	func refreshContent() {
		guard let doc = Doc, let dlg = Dialog else {
			return
		}
		
		// text fields
		_idTextfield.stringValue = dlg.Name
		_directionsTextfield.stringValue = dlg.Directions
		_previewTextfield.stringValue = dlg.Preview
		_contentTextfield.stringValue = dlg.Content
		
		// instigator menu setup
		_instigatorMenu = NSMenu()
		for ent in doc.Story.Entities {
			let item = NSMenuItem(title: ent.Name, action: #selector(DialogViewController.onInstigatorMenuChanged), keyEquivalent: "")
			item.representedObject = ent
			_instigatorMenu?.addItem(item)
		}
		
		// initial instigator image
		if let ent = dlg.Instigator, let entImg = doc.EntityImageNames[ent.ID] {
			_instigatorImgBtn.image = NSImage(byReferencingFile: entImg) ?? NSImage(named: NSImage.cautionName)
		}
	}
	
	/// MARK: - Menu Callbacks
	@objc private func onInstigatorMenuChanged() {
		guard let doc = Doc, let dlg = Dialog, let item = _instigatorMenu?.highlightedItem else {
			return
		}
		
		let ent = item.representedObject as! NVEntity
		dlg.Instigator = ent
		_instigatorImgBtn.image = NSImage(contentsOfFile: doc.EntityImageNames[ent.ID] ?? "") ?? NSImage(named: NSImage.cautionName)
	}
	
	// MARK: - Interface Callbacks
	@IBAction func onInstigatorClicked(_ sender: NSButton) {
		if let instigatorMenu = _instigatorMenu {
			NSMenu.popUpContextMenu(instigatorMenu, with: NSApp.currentEvent!, for: sender)
		}
	}
	
	@IBAction func onIDChanged(_ sender: NSTextField) {
		Dialog?.Name = sender.stringValue
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		Dialog?.Directions = sender.stringValue
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		Dialog?.Preview = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		Dialog?.Content = sender.stringValue
	}
}
