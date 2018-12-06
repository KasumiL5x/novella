//
//  Document.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa
import SwiftyJSON

class Document: NSDocument {
	private(set) var Story: NVStory = NVStory()
	
	override init() {
		super.init()
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		let jsonString = "{}"
		guard let jsonData = jsonString.data(using: .utf8) else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		return jsonData
	}

	override func read(from data: Data, ofType typeName: String) throws {
	}
}
