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
	// MARK: - Outlets -
	@IBOutlet fileprivate weak var _nameTextField: NSTextField!
	
	// MARK: - Variables -
	fileprivate var _contextNode: ContextLinkableView?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		_contextNode = nil
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	override func viewDidAppear() {
		refreshContent()
	}
	
	func setContextNode(node: ContextLinkableView) {
		_contextNode = node
		refreshContent()
	}
	
	func refreshContent() {
		if let asContext = (_contextNode?.Linkable as? NVContext) {
			let name = asContext.Name
			_nameTextField.stringValue = name.isEmpty ? "" : name
		} else {
			_nameTextField.stringValue = ""
		}
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let ctx = _contextNode?.Linkable as? NVContext else {
			return
		}
		ctx.Name = sender.stringValue
	}
}
