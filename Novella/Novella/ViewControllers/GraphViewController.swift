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
	private var _currentPathResult: NVPathResult = ("", [])
	
	func setup(doc: Document) {
		_document = doc
		MainCanvas = Canvas(doc: doc)
		_scrollView.documentView = MainCanvas
		
		MainCanvas!.didSetupGroup = { (group) in
			self.updatePath(to: group)
		}
		MainCanvas!.didSetupBeat = { (beat) in
			self.updatePath(to: beat)
		}
		
		MainCanvas!.setupFor(group: doc.Story.MainGroup)
		
		_pathControl.doubleAction = #selector(GraphViewController.onPathDoubleClick)
	}
	
	@objc func onPathDoubleClick() {
		if let cell = _pathControl.clickedPathComponentCell() {
			let obj = _currentPathResult.objects[cell.tag]
			if let asGroup = obj as? NVGroup, MainCanvas?.MappedGroup != asGroup {
				MainCanvas?.setupFor(group: asGroup)
			} else if let asBeat = obj as? NVBeat, MainCanvas?.MappedBeat != asBeat {
				MainCanvas?.setupFor(beat: asBeat)
			}
		}
	}
	
	private func updatePath(to: NVPathable) {
		_currentPathResult = NVPath.fullPath(to)
		// escape spaces (TODO: Make this happen at the path level in the model)
		_currentPathResult.path = _currentPathResult.path.replacingOccurrences(of: " ", with: "%20")
		
		_pathControl.url = URL(string: _currentPathResult.path)
		for idx in 0..<_pathControl.pathComponentCells().count {
			let cell = _pathControl.pathComponentCells()[idx]
			cell.tag = idx
			switch _currentPathResult.objects[idx] {
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
