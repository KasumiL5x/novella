//
//  GraphDeliveryPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphDeliveryPopoverViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _nameTextField: NSTextField!
	@IBOutlet fileprivate weak var _directionsTextField: NSTextField!
	@IBOutlet fileprivate weak var _previewTextField: NSTextField!
	@IBOutlet fileprivate weak var _contentTextField: NSTextField!
	
	// MARK: - - Variables -
	fileprivate var _deliveryNode: DeliveryLinkableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_deliveryNode = nil
		
	}
	
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	func setDeliveryNode(node: DeliveryLinkableView!) {
		_deliveryNode = node
		
		let delivery = (_deliveryNode!.Linkable as! NVDelivery)
		
		let name = delivery.Name
		_nameTextField.stringValue = name.isEmpty ? "" : name
		
		let dirs = delivery.Preview
		_directionsTextField.stringValue = dirs.isEmpty ? "" : dirs
		
		let prev = delivery.Preview
		_previewTextField.stringValue = prev.isEmpty ? "" : prev
		
		let content = delivery.Content
		_contentTextField.stringValue = content.isEmpty ? "" : content
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Linkable as? NVDelivery else {
			return
		}
		delivery.Name = sender.stringValue
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Linkable as? NVDelivery else {
			return
		}
		delivery.Directions = sender.stringValue
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Linkable as? NVDelivery else {
			return
		}
		delivery.Preview = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Linkable as? NVDelivery else {
			return
		}
		delivery.Content = sender.stringValue
	}
}
