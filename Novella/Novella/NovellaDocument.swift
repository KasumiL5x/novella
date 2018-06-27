//
//  Document.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class NovellaDocument: NSDocument {
	private var _manager: NVStoryManager
	private var _undoRedo: UndoRedo
	private var _curveType: CurveHelper.CurveType
	
	var Manager: NVStoryManager {
		get{ return _manager }
	}
	var Undo: UndoRedo {
		get{ return _undoRedo }
	}
	var CurveType: CurveHelper.CurveType {
		get{ return _curveType }
		set{ _curveType = newValue }
	}

	override init() {
		_manager = NVStoryManager()
		_undoRedo = UndoRedo()
		_curveType = .catmullRom
		super.init()
		_manager.addDelegate(self)
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		let jsonStr = _manager.toJSON()
		if jsonStr.isEmpty {
			throw NSError(domain: NSOSStatusErrorDomain, code: writErr, userInfo: nil)
		}
		if let data = jsonStr.data(using: .utf8) {
			return data
		}
		throw NSError(domain: NSOSStatusErrorDomain, code: writErr, userInfo: nil)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		if let jsonStr = String(data: data, encoding: .utf8) {
			if let loadedManager = NVStoryManager.fromJSON(str: jsonStr) {
				_manager = loadedManager
				_manager.addDelegate(self)
				return
			}
		}
		throw NSError(domain: NSOSStatusErrorDomain, code: readErr, userInfo: nil)
	}
}

extension NovellaDocument: NVStoryDelegate {
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
	func onStoryMakeEntity(entity: NVEntity) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryMakeContext(context: NVContext) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryTrashItem(item: NVObject) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryUntrashItem(item: NVObject) {
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
	func onStoryDeleteGraph(graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeleteEntity(entity: NVEntity) {
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
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryNodePreviewChanged(preview: String, node: NVNode) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryLinkSetDestination(link: NVLink, dest: NVObject?) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVObject?) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVObject?) {
		self.updateChangeCount(.changeDone)
	}
	
	func onStoryFunctionUpdated(function: NVFunction) {
		self.updateChangeCount(.changeDone)
	}
	func onStoryConditionUpdated(condition: NVCondition) {
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

