//
//  DeliveryPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DeliveryPopoverViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _nameTextField: NSTextField!
	@IBOutlet private weak var _directionsTextField: NSTextField!
	@IBOutlet private weak var _previewTextField: NSTextField!
	@IBOutlet private weak var _contentTextField: NSTextField!
	
	// MARK: - Variables -
	private var _deliveryNode: DeliveryNode?
	
	
	// MARK: - Functions -
	override var acceptsFirstResponder: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_deliveryNode = nil
	}
	
	override func viewDidAppear() {
		refreshContent()
	}
	
	func setDeliveryNode(node: DeliveryNode) {
		_deliveryNode = node
		refreshContent()
	}
	
	func refreshContent() {
		if let asDelivery = (_deliveryNode?.Object as? NVDelivery) {
			let name = asDelivery.Name
			_nameTextField.stringValue = name.isEmpty ? "" : name
			
			let dirs = asDelivery.Directions
			_directionsTextField.stringValue = dirs.isEmpty ? "" : dirs
			
			let prev = asDelivery.Preview
			_previewTextField.stringValue = prev.isEmpty ? "" : prev
			
			let content = asDelivery.Content
			_contentTextField.stringValue = content.isEmpty ? "" : content
		}
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Object as? NVDelivery else {
			return
		}
		delivery.Name = sender.stringValue
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Object as? NVDelivery else {
			return
		}
		delivery.Directions = sender.stringValue
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Object as? NVDelivery else {
			return
		}
		delivery.Preview = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		guard let delivery = _deliveryNode?.Object as? NVDelivery else {
			return
		}
		delivery.Content = sender.stringValue
	}
}
