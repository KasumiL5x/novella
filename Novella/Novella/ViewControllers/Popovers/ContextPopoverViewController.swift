//
//  ContextPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class ContextPopoverViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _nameTextField: NSTextField!
	
	// MARK: - - Variables -
	fileprivate var _contextNode: ContextLinkableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_contextNode = nil
		
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	func setContextNode(node: ContextLinkableView!) {
		_contextNode = node
		
		let ctx = (_contextNode!.Linkable as! NVContext)
		
		let name = ctx.Name
		_nameTextField.stringValue = name.isEmpty ? "" : name
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let ctx = _contextNode?.Linkable as? NVContext else {
			return
		}
		ctx.Name = sender.stringValue
	}
}
