//
//  SwitchPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 01/08/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class SwitchOptionPopoverViewController: NSViewController {
	// MARK: - Variables -
	private var _variable: NVVariable?
	private var _option: NVSwitchOption?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_variable = nil
	}
	
	func setVariable(variable: NVVariable, option: NVSwitchOption) {
		_variable = variable
		_option = option
	}
	
	// MARK: Outlet Callbacks
	@IBAction func onValueChanged(_ sender: NSTextField) {
		let ns = NSString(string: sender.stringValue)
		
		switch _variable!.DataType {
		case .boolean:
			_option!.Value = ns.boolValue
		case .double:
			_option!.Value = ns.doubleValue
		case .integer:
			_option!.Value = ns.integerValue
		}
	}
}
