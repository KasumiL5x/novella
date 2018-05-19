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
	@IBOutlet weak var _testTextField: NSTextField!
	
	
	
	// MARK: - - Variables -
	fileprivate var _dialogNode: DialogLinkableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_dialogNode = nil
	}
	
	func setDialogNode(node: DialogLinkableView?) {
		_dialogNode = node
		
		if _dialogNode == nil {
			_testTextField.stringValue = ""
		} else {
			let name = (_dialogNode!.Linkable as! NVDialog).Name
			_testTextField.stringValue = name.isEmpty ? "no name" : name
		}
		
	}
}
