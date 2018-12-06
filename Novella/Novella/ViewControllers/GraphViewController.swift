//
//  GraphViewController.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class GraphViewController: NSViewController {
	@IBOutlet weak private var _scrollView: NSScrollView!
	private var _document: Document? = nil
	private(set) var MainCanvas: Canvas? = nil
	
	func setup(doc: Document) {
		_document = doc
		MainCanvas = Canvas()
		_scrollView.documentView = MainCanvas
	}
}
