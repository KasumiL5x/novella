//
//  EntitiesEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 16/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class EntitiesEditorViewController: NSViewController {
	private var _document: Document? = nil
	
	func setup(doc: Document) {
		_document = doc
	}
}
