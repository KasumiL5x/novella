//
//  DeliveryViewController.swift
//  novella
//
//  Created by dgreen on 14/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class DeliveryViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _instigatorImgBtn: NSButton!
	@IBOutlet weak var _idTextfield: NSTextField!
	@IBOutlet weak var _directionsTextfield: NSTextField!
	@IBOutlet weak var _previewTextfield: NSTextField!
	@IBOutlet weak var _contentTextfield: NSTextField!
	
	// MARK: - Variables
	private var _instigatorMenu: NSMenu?
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			refreshContent()
		}
	}
	var Delivery: NVDelivery? {
		didSet {
			refreshContent()
		}
	}
	
	func refreshContent() {
		guard /*let doc = Doc,*/ let delivery = Delivery else {
			return
		}
		
		// text fields
		_idTextfield.stringValue = delivery.Name
		_directionsTextfield.stringValue = delivery.Directions
		_previewTextfield.stringValue = delivery.Preview
		_contentTextfield.stringValue = delivery.Content
		
		// initial instigator image
		print("Delivery doesn't have an instigator yet.  Will add in the future.")
	}
	
	// MARK: - Interface Callbacks
	@IBAction func onIDChanged(_ sender: NSTextField) {
		Delivery?.Name = sender.stringValue
	}
	
	@IBAction func onDirectionsChanged(_ sender: NSTextField) {
		Delivery?.Directions = sender.stringValue
	}
	
	@IBAction func onPreviewChanged(_ sender: NSTextField) {
		Delivery?.Preview = sender.stringValue
	}
	
	@IBAction func onContentChanged(_ sender: NSTextField) {
		Delivery?.Content = sender.stringValue
	}
}
