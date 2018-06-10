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
	var _snapshot: NVStoryManager?

	override init() {
		_manager = NVStoryManager()
		_snapshot = nil
		super.init()
		_manager.addDelegate(self)
	}

	override class var autosavesInPlace: Bool {
		return true
	}
	
	func snapshot() {
		_snapshot = _manager.snapshot()
	}
	
	func restore() {
		if _snapshot != nil {
			_manager.restore(snapshot: _snapshot!)
			_snapshot = nil
		}
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		let vc = windowController.contentViewController as! MainViewController
		vc.setManager(manager: _manager)
		self.addWindowController(windowController)
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
				_manager.addDelegate(self)
				return
			}
		}
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}
}

extension Document: NVStoryDelegate {
	func onStoryMakeFolder(folder: NVFolder) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeVariable(variable: NVVariable) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeGraph(graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeLink(link: NVLink) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeBranch(branch: NVBranch) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeSwitch(switch: NVSwitch) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeDialog(dialog: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeContext(context: NVContext) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryNodePositionChanged(node: NVNode, oldPos: CGPoint, newPos: CGPoint) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphPositionChanged(graph: NVGraph, oldPos: CGPoint, newPos: CGPoint) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryTrashItem(item: NVLinkable) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryUntrashItem(item: NVLinkable) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeleteVariable(variable: NVVariable) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeleteNode(node: NVNode) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeleteLink(link: NVBaseLink) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryAddFolder(folder: NVFolder) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryRemoveFolder(folder: NVFolder) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryAddGraph(graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryRemoveGraph(graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphSetName(oldName: String, newName: String, graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryGraphSetEntry(entry: NVLinkable, graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryNodeNameChanged(oldName: String, newName: String, node: NVNode) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDialogPreviewChanged(preview: String, node: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeliveryPreviewChanged(preview: String, node: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryLinkSetDestination(link: NVLink, dest: NVLinkable?) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVLinkable?) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVLinkable?) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryVariableNameChanged(variable: NVVariable, name: String) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryVariableSynopsisChanged(variable: NVVariable, synopsis: String) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryVariableTypeChanged(variable: NVVariable, type: NVDataType) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryVariableValueChanged(variable: NVVariable, value: Any) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryVariableInitialValueChanged(variable: NVVariable, value: Any) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryVariableConstantChanged(variable: NVVariable, constant: Bool) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryFolderNameChanged(folder: NVFolder, name: String) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryFolderSynopsisChanged(folder: NVFolder, synopsis: String) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryFolderAddFolder(parent: NVFolder, child: NVFolder) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryFolderRemoveFolder(parent: NVFolder, child: NVFolder) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryFolderAddVariable(parent: NVFolder, child: NVVariable) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryFolderRemoveVariable(parent: NVFolder, child: NVVariable) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryNameChanged(story: NVStory, name: String) {
		self.updateChangeCount(.changeDone)
	}
}

