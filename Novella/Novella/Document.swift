//
//  Document.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class Document: NSDocument {
	var _manager: NVStoryManager

	override init() {
		_manager = NVStoryManager()
		super.init()
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		let vc = windowController.contentViewController as! MainViewController
		vc.setManager(manager: _manager)
		self.addWindowController(windowController)
		

		
		// for some reason i cannot have Manager set here thus a crash w/o open
	}

	override func data(ofType typeName: String) throws -> Data {
		let jsonStr = _manager.toJSON()
		if let data = jsonStr.data(using: .utf8) {
		return data
	}

		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
		
		if let jsonStr = String(data: data, encoding: .utf8) {
			if let loadedManager = NVStoryManager.fromJSON(str: jsonStr) {
				_manager = loadedManager
				return
			}
		}
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}


}

