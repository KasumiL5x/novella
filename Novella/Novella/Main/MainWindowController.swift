//
//  MainWindowController.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	// MARK: - Toolbar Callbacks -
	@IBAction func onToolbarUndo(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.undo()
	}
	
	@IBAction func onToolbarRedo(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.redo()
	}
	
	@IBAction func onToolbarZoomSelected(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.zoomActiveGraph()
	}
	
	@IBAction func onToolbarCenterView(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.centerActiveGraph()
	}
	
	@IBAction func onToolbarCurveType(_ sender: NSSegmentedControl) {
		switch sender.selectedSegment {
		case 0:
			(document as? NovellaDocument)?.CurveType = .line
		case 1:
			(document as? NovellaDocument)?.CurveType = .smooth
		case 2:
			(document as? NovellaDocument)?.CurveType = .curve
		case 3:
			(document as? NovellaDocument)?.CurveType = .square
		default:
			break
		}
		(contentViewController as? MainViewController)?.refreshOpenGraphs()
	}
	
	
	@IBAction func onToolbarScreenshot(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.screenshot()
	}
	
	@IBAction func onToolbarVariableEditor(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.openVariableEditor()
	}
}
