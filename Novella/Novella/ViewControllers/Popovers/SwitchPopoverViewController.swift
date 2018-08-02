//
//  SwitchPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 02/08/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class SwitchPopoverViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet weak var _variablesPopup: NSPopUpButton!
	
	// MARK: - Variables -
	private var _switch: NVSwitch?
	private var _doc: NovellaDocument?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_switch = nil
	}
	
	func setSwitch(swtch: NVSwitch, doc: NovellaDocument) {
		self._switch = swtch
		self._doc = doc
		
		// setup menus
		_variablesPopup.removeAllItems()
		_variablesPopup.addItem(withTitle: "None")
		for curr in doc.Manager.Variables {
			let item = NSMenuItem()
			item.title = NVPath.fullPathTo(curr)
			item.representedObject = curr
			_variablesPopup.menu?.addItem(item)
		}
		
		// select current variable if there is one
		if let selectedVariable = _switch?.Variable {
			for curr in _variablesPopup.menu!.items {
				if nil == curr.representedObject { // ignore "None"
					continue
				}
				if (curr.representedObject as! NVVariable) == selectedVariable {
					_variablesPopup.select(curr)
					break
				}
				
			}
		}
	}
	
	// MARK: Outlet Callbacks
	@IBAction func onVariableChanged(_ sender: NSPopUpButton) {
		var variable: NVVariable? = nil
		
		if sender.selectedItem?.title == "None" {
			variable = nil
		} else {
			variable = sender.selectedItem?.representedObject as? NVVariable
		}
		
		_switch?.Variable = variable
	}
}
