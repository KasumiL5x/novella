//
//  ContextPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 20/11/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class ContextPopoverViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _idTextfield: NSTextField!
	@IBOutlet weak var _contentTextfield: NSTextField!
	
	// MARK: - Properties
	var Context: NVContext? {
		didSet {
			refreshContent()
		}
	}
	
	func refreshContent() {
		guard let ctx = Context else {
			return
		}
		
		_idTextfield.stringValue = ctx.Name
		_contentTextfield.stringValue = ctx.Content
	}
	
	// MARK: - Interface Callbacks
	@IBAction func onIDChanged(_ sender: NSTextField) {
		Context?.Name = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		Context?.Content = sender.stringValue
	}
}
