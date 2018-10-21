//
//  GraphViewController.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class GraphViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _scrollView: NSScrollView!
	
	// MARK: - Variables
	private var _document: Document? = nil
	
	// MARK: - Properties
	private(set) var MainCanvas: Canvas? = nil
	
	// MARK: - Functions
	func setup(doc: Document) {
		_document = doc
		
		MainCanvas = Canvas(doc: doc, graph: doc.Story.MainGraph!)
		_scrollView.documentView = MainCanvas
	}
	
	func centerOfCanvas() -> CGPoint {
		let centerSelf = NSMakePoint(view.frame.width * 0.5, view.frame.height * 0.5)
		return MainCanvas?.convert(centerSelf, from: view) ?? NSPoint.zero
	}
}
