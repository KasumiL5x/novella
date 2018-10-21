//
//  PreviewViewController.swift
//  novella
//
//  Created by Daniel Green on 05/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class PreviewViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _instigatorImage: NSImageView!
	@IBOutlet weak var _title: NSTextField!
	@IBOutlet weak var _directions: NSTextField!
	@IBOutlet var _content: NSTextView!
	@IBOutlet weak var _choiceWheel: ChoiceWheel!
	
	// MARK: - Variables
	private var _reader: NVReader?
	private var _chosenSegmentIndex = -1
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			if let doc = Doc {
				_reader = NVReader(story: doc.Story, delegate: self)
			}
		}
	}
	var Graph: NVGraph? {
		didSet {
			if let graph = Graph {
				_reader?.read(graph: graph, at: nil)
			}
		}
	}
	
	override func viewWillAppear() {
		_choiceWheel.ClickHandler = { (idx: Int) in
			if idx != -1 {
				self._chosenSegmentIndex = idx
				self._reader?.next()
			}
		}
	}
	
	// MARK: - Functions
	@IBAction func onSkip(_ sender: NSButton) {
	}
}

extension PreviewViewController: NVReaderDelegate {
	func readerNodeWillConsume(node: NVNode, outputs: [NVTransfer]) {
		// set ui content
		switch node {
		case let asDialog as NVDialog:
			_title.stringValue = "Dialog"
			_directions.stringValue = asDialog.Directions
			_content.string = asDialog.Content
			if let instigator = asDialog.Instigator {
				_instigatorImage.image = NSImage(byReferencingFile: Doc?.EntityImageNames[instigator.ID] ?? "") ?? NSImage(named: NSImage.cautionName)
			} else {
				_instigatorImage.image = NSImage(named: NSImage.cautionName)
			}
			
		case let asDelivery as NVDelivery:
			_title.stringValue = "Delivery"
			_directions.stringValue = asDelivery.Directions
			_content.string = asDelivery.Content
			_instigatorImage.image = nil
			
		default:
			_title.stringValue = "ERROR"
			_directions.stringValue = ""
			_content.string = ""
			_instigatorImage.image = nil
		}
		
		// set choice wheel
		var options: [String] = []
		for xfer in outputs {
			let text: String
			switch xfer.Destination {
			case let asDialog as NVDialog:
				text = asDialog.Preview.isEmpty ? asDialog.Name : asDialog.Preview
				
			case let asDelivery as NVDelivery:
				text = asDelivery.Preview.isEmpty ? asDelivery.Name : asDelivery.Preview
				
			case is NVBranch:
				text = "Branch"
				
			case is NVSwitch:
				text = "Switch"
				
			default:
				text = "Invalid"
			}
			options.append(text)
		}
		_choiceWheel.setup(items: options)
	}
	
	func readerLinkWillFollow(outputs: [NVTransfer]) -> NVTransfer {
		return outputs[_chosenSegmentIndex]
	}
}
