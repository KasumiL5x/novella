//
//  NewReaderViewController.swift
//  Novella
//
//  Created by Daniel Green on 12/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class NewReaderViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet weak var _graphPopup: NSPopUpButton!
	internal var _document: NovellaDocument?
	
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
	}
}
