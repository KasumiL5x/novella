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
	@IBOutlet private weak var _choiceWheel: ChoiceWheelView!
	internal var _document: NovellaDocument?
	private var _reader: NVReader?
	
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
	}
	
	// MARK: Interface Callbacks
	@IBAction func onGraphPopupChanged(_ sender: NSPopUpButton) {
		print("changed to \(sender.selectedItem!.title)")
	}
}

extension NewReaderViewController: NVReaderDelegate {
	func readerNodeWillConsume(node: NVNode, outputs: [NVBaseLink]) {
		// TODO: Grab this from the destinations of the outputs.
		var options: [String] = []
		options.append("Option 1")
		options.append("Option 2")
		options.append("Option 3")
		_choiceWheel.setup(options: options)
	}
	
	func readerLinkWillFollow(outputs: [NVBaseLink]) -> NVBaseLink {
		return outputs[0]
	}
}
