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
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_variable = nil
	}
	
	func setVariable(variable: NVVariable) {
		_variable = variable
	}
}
