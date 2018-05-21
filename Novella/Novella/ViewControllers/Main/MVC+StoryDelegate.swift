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
		_mvc.reloadBrowser()
	}
	func onStoryMakeVariable(variable: NVVariable) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeGraph(graph: NVGraph) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeLink(link: NVLink) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeBranch(branch: NVBranch) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeSwitch(switch: NVSwitch) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeDialog(dialog: NVDialog) {
		_mvc.reloadBrowser()
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
		_mvc.reloadBrowser()
	}
	
	func onStoryAddFolder(folder: NVFolder) {
		_mvc.reloadBrowser()
	}
	func onStoryRemoveFolder(folder: NVFolder) {
		_mvc.reloadBrowser()
	}
	func onStoryAddGraph(graph: NVGraph) {
		_mvc.reloadBrowser()
	}
	func onStoryRemoveGraph(graph: NVGraph) {
		_mvc.reloadBrowser()
	}
	
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
		print("Added graph \(graph.Name) to graph \(parent.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
		print("Added node \(node.Name) to graph \(parent.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
		print("Added link \(link.UUID) to graph \(parent.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
		print("Added listener \(listener.UUID) to graph \(parent.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph) {
		print("Added exit \(exit.UUID) to graph \(parent.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
		print("Removed graph \(graph.Name) from graph \(from.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
		print("Removed node \(node.Name) from graph \(from.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
		print("Removed link \(link.UUID) from graph \(from.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
		print("Removed listener \(listener.UUID) from graph \(from.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph) {
		print("Removed exit \(exit.UUID) from graph \(from.Name).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphSetName(oldName: String, newName: String, graph: NVGraph) {
		print("Changed graph's name from (\(oldName)) to (\(newName)).")
		_mvc.reloadBrowser()
	}
	func onStoryGraphSetEntry(entry: NVLinkable, graph: NVGraph) {
		print("Changed graph's entry to \(entry.UUID).")
		_mvc.reloadBrowser()
	}
	
	func onStoryNodeNameChanged(oldName: String, newName: String, node: NVNode) {
		print("Changed node's name from \(oldName) to \(newName).")
		_mvc.reloadBrowser()
		_mvc.reloadInspector()
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		print("Changed dialog's content to \"\(content)\".")
		_mvc.reloadInspector()
	}
	func onStoryDialogPreviewChanged(preview: String, node: NVDialog) {
		print("Changed dialog's preview to \"\(preview)\".")
		_mvc.reloadInspector()
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
		print("Changed dialog's directions to \"\(directions)\".")
		_mvc.reloadInspector()
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		print("Changed delivery's content to \"\(content)\".")
		_mvc.reloadInspector()
	}
	func onStoryDeliveryPreviewChanged(preview: String, node: NVDelivery) {
		print("Changed delivery's preview to \"\(preview)\".")
		_mvc.reloadInspector()

	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
		print("Changed delivery's directions to \"\(directions)\".")
		_mvc.reloadInspector()
	}
}
