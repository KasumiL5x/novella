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
	@IBOutlet weak private var _pathControl: NSPathControl!
	
	private var _document: Document? = nil
	private(set) var MainCanvas: Canvas? = nil
	
	func setup(doc: Document) {
		_document = doc
		MainCanvas = Canvas(doc: doc)
		_scrollView.documentView = MainCanvas
		
		
		//
		var fullPath = NVPath.fullPath(doc.Story.MainGroup)
		fullPath.path = fullPath.path.replacingOccurrences(of: " ", with: "%20")
		_pathControl.url = URL(string: fullPath.path)
		for idx in 0..<_pathControl.pathComponentCells().count {
			let cell = _pathControl.pathComponentCells()[idx]
			cell.target = fullPath.objects[idx] as AnyObject // hack: use this to store the object (it's not supposed to be used for it)
			// todo: look into just storing the latest array or sth, shouldn't be hard at all
			switch cell.target {
			case is NVGroup:
				cell.image = NSImage(named: NSImage.folderName)
			case is NVBeat:
				cell.image = NSImage(named: NSImage.cautionName)
			case is NVEvent:
				cell.image = NSImage(named: NSImage.cautionName)
			default:
				cell.image = NSImage(named: NSImage.cautionName)
			}
		}
	}
}
