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
	// MARK: - Variables -
	private var _switch: NVSwitch?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_switch = nil
	}
	
	func setSwitch(swtch: NVSwitch) {
		self._switch = swtch
	}
}
