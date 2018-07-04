//
//  MainWindowController.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	@IBOutlet private weak var _emptyTrashButton: NSButton!
	private lazy var _trashEmptyImage: NSImage? = {
		return NSImage(named: NSImage.Name.trashEmpty)
	}()
	private lazy var _trashFullImage: NSImage? = {
		return NSImage(named: NSImage.Name.trashFull)
	}()
	
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
		(contentViewController as? MainViewController)?.zoomGraph()
	}
	
	@IBAction func onToolbarCenterView(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.centerActiveGraph()
	}
	
	@IBAction func onToolbarEmptyTrash(_ sender: NSButton) {
		(self.document as? NovellaDocument)?.Manager.emptyTrash()
		setTrashIcon(false)
	}
	func setTrashIcon(_ full: Bool) {
		_emptyTrashButton.image = full ? _trashFullImage : _trashEmptyImage
	}
	
	@IBAction func onToolbarCurveType(_ sender: NSSegmentedControl) {
		switch sender.selectedSegment {
		case 0:
			(document as? NovellaDocument)?.CurveType = .catmullRom
		case 1:
			(document as? NovellaDocument)?.CurveType = .square
		case 2:
			(document as? NovellaDocument)?.CurveType = .line
		default:
			break
		}
		(contentViewController as? MainViewController)?.refreshOpenGraphs()
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == NSStoryboardSegue.Identifier(rawValue: "PreviewSegue") {
			guard let doc = self.document as? NovellaDocument, let vc = segue.destinationController as? ReaderWindowController else {
				return
			}
			vc.setDocument(doc: doc)
		}
		
		if segue.identifier == NSStoryboardSegue.Identifier(rawValue: "VariableSegue") {
			guard let doc = self.document as? NovellaDocument, let vc = segue.destinationController as? VariableTabViewController else {
				return
			}
			vc.setup(doc: doc)
		}
		
		if segue.identifier == NSStoryboardSegue.Identifier(rawValue: "EntitySegue") {
			guard let doc = self.document as? NovellaDocument, let vc = segue.destinationController as? EntityTabViewController else {
				return
			}
			vc.setup(doc: doc)
		}
	}
	
	@IBAction func onToolbarScreenshot(_ sender: NSButton) {
		(contentViewController as? MainViewController)?.screenshot()
	}
}
