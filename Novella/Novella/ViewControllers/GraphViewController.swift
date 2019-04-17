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
	@IBOutlet weak private var _currentZoomLevel: NSTextField!
	
	
	func setup(doc: Document) {
		_document = doc
		MainCanvas = Canvas(doc: doc)
		_scrollView.documentView = MainCanvas
		
		NotificationCenter.default.addObserver(self, selector: #selector(GraphViewController.onCanvasSetupForGroup), name: NSNotification.Name.nvCanvasSetupForGroup, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GraphViewController.onCanvasSetupForSequence), name: NSNotification.Name.nvCanvasSetupForSequence, object: nil)
		
		MainCanvas!.setupFor(group: doc.Story.MainGroup)
		
		_pathControl.doubleAction = #selector(GraphViewController.onPathDoubleClick)
		
		// set up callback for the scroll view's clip view bounds change so we can update the magnification label (this unfortunately includes moving, too)
		_scrollView.contentView.postsBoundsChangedNotifications = true
		NotificationCenter.default.addObserver(self, selector: #selector(GraphViewController.onScrollViewChanged), name: NSView.boundsDidChangeNotification, object: _scrollView.contentView)
		updateZoomLabel()
	}
	
	@objc private func onCanvasSetupForGroup(_ sender: NSNotification) {
		guard let group = sender.userInfo?["group"] as? NVGroup else {
			return
		}
		self.updatePath(to: group)
	}
	
	@objc private func onCanvasSetupForSequence(_ sender: NSNotification) {
		guard let sequence = sender.userInfo?["sequence"] as? NVSequence else {
			return
		}
		self.updatePath(to: sequence)
	}
	
	@objc func onPathDoubleClick() {
		if let cell = _pathControl.clickedPathComponentCell() {
			let obj = _currentPathResult.objects[cell.tag]
			if let asGroup = obj as? NVGroup, MainCanvas?.MappedGroup != asGroup {
				MainCanvas?.setupFor(group: asGroup)
			} else if let asSequence = obj as? NVSequence, MainCanvas?.MappedSequence != asSequence {
				MainCanvas?.setupFor(sequence: asSequence)
			}
		}
	}
	
	@objc func onScrollViewChanged() {
		updateZoomLabel()
	}
	private func updateZoomLabel() {
		// regular percent out of 100
		let minMag = _scrollView.minMagnification
		let maxMag = _scrollView.maxMagnification
		var percent = (_scrollView.magnification - minMag) / (maxMag - minMag)
		// clamp as macos can slightly go beyond both ways for its elastic physics
		percent = min(100.0, max(0.0, percent * 100.0))
		
		// label with formatting to 2 decimal places
		_currentZoomLevel.stringValue = "\(String(format: "%.2f", percent))%"
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
				cell.image = NSImage(named: "NVGroup") ?? NSImage(named: NSImage.cautionName)
			case is NVSequence:
				cell.image = NSImage(named: "NVSequence") ?? NSImage(named: NSImage.cautionName)
			case is NVEvent:
				cell.image = NSImage(named: "NVEvent") ?? NSImage(named: NSImage.cautionName)
			default:
				cell.image = NSImage(named: NSImage.cautionName)
			}
		}
	}
	
	@IBAction func onDebugPrint(_ sender: NSButton) {
		_document?.Story.debugPrint()
	}
}
