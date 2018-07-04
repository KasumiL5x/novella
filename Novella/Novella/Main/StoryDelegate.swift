//
//  MVC+StoryDelegate.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import NovellaModel

class StoryDelegate: NVStoryDelegate {
	let _mvc: MainViewController
	
	init(mvc: MainViewController) {
		self._mvc = mvc
	}
	
	func onStoryMakeFolder(folder: NVFolder) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeVariable(variable: NVVariable) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeGraph(graph: NVGraph) {
		_mvc.reloadAllGraphs()
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeLink(link: NVLink) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeBranch(branch: NVBranch) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeSwitch(switch: NVSwitch) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeDialog(dialog: NVDialog) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeEntity(entity: NVEntity) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryMakeContext(context: NVContext) {
		_mvc.reloadSelectedGraph()
	}
	
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint) {
	}
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String) {
		_mvc.reloadSelectedGraph()
	}
	
	func onStoryTrashItem(item: NVObject) {
		_mvc.reloadSelectedGraph()
		
		(_mvc.view.window?.windowController as? MainWindowController)?.setTrashIcon(true)
	}
	func onStoryUntrashItem(item: NVObject) {
		_mvc.reloadSelectedGraph()
		
		(_mvc.view.window?.windowController as? MainWindowController)?.setTrashIcon(_mvc.Document.Manager.TrashedItems.count > 0)
	}
	
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryDeleteVariable(variable: NVVariable) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryDeleteLink(link: NVBaseLink) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryDeleteNode(node: NVNode) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryDeleteGraph(graph: NVGraph) {
		_mvc.reloadAllGraphs()
		_mvc.reloadSelectedGraph()
	}
	
	func onStoryAddFolder(folder: NVFolder) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryRemoveFolder(folder: NVFolder) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryAddGraph(graph: NVGraph) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryRemoveGraph(graph: NVGraph) {
		_mvc.reloadSelectedGraph()
	}
	func onStoryDeleteEntity(entity: NVEntity) {
		_mvc.reloadSelectedGraph()
	}
	
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
		print("Added graph \(graph.Name) to graph \(parent.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
		print("Added node \(node.Name) to graph \(parent.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
		print("Added link \(link.UUID) to graph \(parent.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
		print("Added listener \(listener.UUID) to graph \(parent.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph) {
		print("Added exit \(exit.UUID) to graph \(parent.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
		print("Removed graph \(graph.Name) from graph \(from.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
		print("Removed node \(node.Name) from graph \(from.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
		print("Removed link \(link.UUID) from graph \(from.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
		print("Removed listener \(listener.UUID) from graph \(from.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph) {
		print("Removed exit \(exit.UUID) from graph \(from.Name).")
		_mvc.reloadSelectedGraph()
	}
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
		print("Changed graph's entry to \(entry.UUID).")
		_mvc.reloadSelectedGraph()
	}
	
	func onStoryNodePreviewChanged(preview: String, node: NVNode) {
		print("Changed node's preview to \"\(preview)\".")
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		print("Changed dialog's content to \"\(content)\".")
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
		print("Changed dialog's directions to \"\(directions)\".")
	}
	func onStoryDialogSpeakerChanged(speaker: NVEntity?, node: NVDialog) {
		print("Changed dialog's speaker to \"\(speaker?.Name ?? "none")\".")
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		print("Changed delivery's content to \"\(content)\".")
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
		print("Changed delivery's directions to \"\(directions)\".")
	}
}
