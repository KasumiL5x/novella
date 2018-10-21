//
//  SwitchViewController.swift
//  novella
//
//  Created by dgreen on 18/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class SwitchViewController: NSViewController {
	@IBOutlet weak var _variablesPopup: NSPopUpButton!
	private var _switch: NVSwitch?
	
	func setup(story: NVStory, swtch: NVSwitch) {
		_switch = swtch
		
		// start afresh otherwise this will keep adding when reopened (we DO want
		// it to re-add as the varibles may have changed, but not append).
		_variablesPopup.menu?.removeAllItems()
		
		// add "None" option
		let noneItem = NSMenuItem(title: "None", action: nil, keyEquivalent: "")
		noneItem.tag = -1
		_variablesPopup.menu?.addItem(noneItem)
		_variablesPopup.selectItem(withTag: -1)
		
		// add all variables
		for variable in story.Variables  {
			let menuItem = NSMenuItem(title: NVPath.fullPath(variable), action: nil, keyEquivalent: "")
			menuItem.tag = variable.ID.hash // store UUID hash as tag for lookup
			menuItem.representedObject = variable // store reference to variable to save time looking up by hash later
			_variablesPopup.menu?.addItem(menuItem)
		}
		
		// select existing variable if it's present
		if let variable = swtch.Variable {
			_variablesPopup.selectItem(withTag: variable.ID.hash)
		}
	}
	
	@IBAction func onVariablesPopupChanged(_ sender: NSPopUpButton) {
		guard let selection = _variablesPopup.selectedItem else {
			return
		}
		
		// handle case of 'None'
		if selection.title == "None" {
			_switch?.Variable = nil
			return
		}
		
		guard let variable = selection.representedObject as? NVVariable else {
			print("SwitchViewController changed variable to \(selection.title) but couldn't find the NVVariable.")
			return
		}
		_switch?.Variable = variable
	}
}
