//
//  NewReaderViewController.swift
//  Novella
//
//  Created by Daniel Green on 12/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class NewReaderViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _graphPopup: NSPopUpButton!
	@IBOutlet private weak var _titleLabel: NSTextField!
	@IBOutlet private weak var _directionsLabel: NSTextField!
	@IBOutlet private weak var _contentLabel: TypewriterLabel!
	@IBOutlet private weak var _choiceWheel: ChoiceWheelView!
	internal var _document: NovellaDocument?
	private var _reader: NVReader?
	private var _chosenLinkIndex: Int = -1
	
	// MARK: - Functions -
	
	// MARK: ViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		_document = nil
	}
	
	override func viewWillAppear() {
		guard let document = _document else {
			print("Document was nil when reader VC appeared.")
			return
		}
		
		// make menu
		_graphPopup.removeAllItems()
		_graphPopup.addItems(withTitles: document.Manager.Story.Graphs.map{$0.Name})
		
		// set up reader
		_reader = NVReader(manager: document.Manager, delegate: self)
		
		if let startGraph = document.Manager.Story.Graphs.first {
			_reader?.start(startGraph, atNode: nil)
		}
		
		_choiceWheel.ClickHandler = { (idx: Int) in
			if idx != -1 {
				self._chosenLinkIndex = idx
				self._reader?.next()
			}
		}
	}
	
	// MARK: Interface Callbacks
	@IBAction func onGraphPopupChanged(_ sender: NSPopUpButton) {
		print("changed to \(sender.selectedItem!.title)")
	}
	
	@IBAction func onSkipPressed(_ sender: NSButton) {
		_contentLabel.skipTypewritingAnimation()
	}
}

extension NewReaderViewController: NVReaderDelegate {
	func readerNodeWillConsume(node: NVNode, outputs: [NVBaseLink]) {
		switch node {
		case is NVDialog:
			_titleLabel.stringValue = "Dialog"
			_directionsLabel.stringValue = (node as! NVDialog).Directions
			_contentLabel.stringValue = (node as! NVDialog).Content
			_contentLabel.startTypewritingAnimation(completion: {print("done")})
			
		case is NVDelivery:
			_titleLabel.stringValue = "Delivery"
			_directionsLabel.stringValue = (node as! NVDelivery).Directions
			_contentLabel.stringValue = (node as! NVDelivery).Content
			_contentLabel.startTypewritingAnimation(completion: {print("done")})
			
		case is NVContext:
			_titleLabel.stringValue = "Context"
			_directionsLabel.stringValue = ""
			_contentLabel.stringValue = ""
			
		default:
			_titleLabel.stringValue = "INVALID"
			_directionsLabel.stringValue = ""
			_contentLabel.stringValue = ""
		}
		
		var options: [String] = []
		for base in outputs {
			switch base {
			case is NVLink:
				var str = "Invalid Link"
				if let dest = (base as! NVLink).Transfer.Destination {
					if let asNode = dest as? NVNode {
						str = asNode.Preview.isEmpty ? asNode.Name : asNode.Preview
					} else {
						str = "Non-NVNode: " + dest.Name
					}
				}
				options.append(str)
				
			case is NVBranch:
				var str = "Invalid Branch"
				if let trueDest = (base as! NVBranch).TrueTransfer.Destination, let falseDest = (base as! NVBranch).FalseTransfer.Destination {
					if let trueAsNode = trueDest as? NVNode, let falseAsNode = falseDest as? NVNode {
						str = (trueAsNode.Preview.isEmpty ? trueAsNode.Name : trueAsNode.Preview) + "/" + (falseAsNode.Preview.isEmpty ? falseAsNode.Name : falseAsNode.Preview)
					} else {
						str = "Non-NVNode: \(trueDest.Name) / Non-NVNode: \(falseDest.Name)"
					}
				}
				options.append(str)
				
			default:
				break
			}
		}
		_choiceWheel.setup(options: options)
	}
	
	func readerLinkWillFollow(outputs: [NVBaseLink]) -> NVBaseLink {
		return outputs[_chosenLinkIndex]
	}
}
