//
//  NVStory+Delegate.swift
//  NovellaModel
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

// MARK: - - Main Delegate -
public protocol NVStoryDelegate {
	// Called when an NVFolder is created using Story.makeFolder().
	func onStoryMakeFolder(folder: NVFolder)
	// Called when an NVVariable is created using Story.makeVariable().
	func onStoryMakeVariable(variable: NVVariable)
	// Called when an NVGraph is created using Story.makeGraph().
	func onStoryMakeGraph(graph: NVGraph)
	// Called when an NVLink is created using Story.makeLink().
	func onStoryMakeLink(link: NVLink)
	// Called when an NVBranch is created using Story.makeBranch().
	func onStoryMakeBranch(branch: NVBranch)
	// Called when an NVSwitch is created using Story.makeSwitch().
	func onStoryMakeSwitch(switch: NVSwitch)
	// Called when an NVDialog is created using Story.makeDialog().
	func onStoryMakeDialog(dialog: NVDialog)
	// Called when an NVDelivery is created using Story.makeDelivery.
	func onStoryMakeDelivery(delivery: NVDelivery)
	
	// Called when an NVFolder is added to the Story using Story.add(folder).
	func onStoryAddFolder(folder: NVFolder)
	// Called when an NVFolder is removed from the Story using Story.remove(folder).
	func onStoryRemoveFolder(folder: NVFolder)
	// Called when an NVGraph is added to the Story using Story.add(graph).
	func onStoryAddGraph(graph: NVGraph)
	// Called when an NVGraph is removed from the Story using Story.remove(graph).
	func onStoryRemoveGraph(graph: NVGraph)
	
	// Called when an NVGraph is added to an NVGraph using NVGraph.add(graph).
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph)
	// Called when an NVNode (or derived class) is added to an NVGraph using NVGraph.add(node).
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph)
	// Called when an NVBaseLink (or derived class) is added to an NVGraph using NVGraph.add(link).
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph)
	// Called when an NVListener is added to an NVGraph using NVGraph.add(listener).
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph)
	// Called when an NVExitNode is added to an NVGraph using NVGraph.add(exit).
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph)
	// Called when an NVGraph is removed from an NVGraph using NVGraph.remove(graph).
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph)
	// Called when an NVNode (or derived class) is removed from an NVGraph using NVGraph.remove(node).
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph)
	// Called when an NVBaseLink (or derived class) is removed from NVGraph using NVGraph.remove(link).
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph)
	// Called when an NVListener is removed from an NVGraph using NVGraph.remove(listener).
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph)
	// Called when an NVExitNode is removed from an NVGraph using NVGraph.remove(exit).
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph)
	// Called when an NVGraph's name is changed using NVGraph.setName().
	func onStoryGraphSetName(oldName: String, newName: String, graph: NVGraph)
	// Called when an NVGraph's entry is set using NVGraph.setEntry().
	func onStoryGraphSetEntry(entry: NVLinkable, graph: NVGraph)
	
	// Called when an NVNode's name is changed using NVNode.Name.
	func onStoryNodeNameChanged(oldName: String, newName: String, node: NVNode)
	// Called when an NVDialog's content is changed using NVDialog.Content.
	func onStoryDialogContentChanged(content: String, node: NVDialog)
	// Called when an NVDialog's preview is changed using NVDialog.Preview.
	func onStoryDialogPreviewChanged(preview: String, node: NVDialog)
	// Called when an NVDialog's directions are changed using NVDialog.Directions.
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog)
	// Called when an NVDelivery's content is changed using NVDelivery.Content.
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery)
	// Called when an NVDelivery's preview is changed using NVDeliveryPreview.
	func onStoryDeliveryPreviewChanged(preview: String, node: NVDelivery)
	// Called when an NVDelivery's directions are changed using NVDelivery.Directions.
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery)
}

// MARK: - - Default Implementations -
public extension NVStoryDelegate {
	func onStoryMakeFolder(folder: NVFolder) {
	}
	func onStoryMakeVariable(variable: NVVariable) {
	}
	func onStoryMakeGraph(graph: NVGraph) {
	}
	func onStoryMakeLink(link: NVLink) {
	}
	func onStoryMakeBranch(branch: NVBranch) {
	}
	func onStoryMakeSwitch(switch: NVSwitch) {
	}
	func onStoryMakeDialog(dialog: NVDialog) {
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
	}
	
	func onStoryAddFolder(folder: NVFolder) {
	}
	func onStoryRemoveFolder(folder: NVFolder) {
	}
	func onStoryAddGraph(graph: NVGraph) {
	}
	func onStoryRemoveGraph(graph: NVGraph) {
	}
	
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
	}
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph) {
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
	}
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph) {
	}
	func onStoryGraphSetName(oldName: String, newName: String, graph: NVGraph) {
	}
	func onStoryGraphSetEntry(entry: NVLinkable, graph: NVGraph) {
	}
	
	func onStoryNodeNameChanged(oldName: String, newName: String, node: NVNode) {
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
	}
	func onStoryDialogPreviewChanged(preview: String, node: NVDialog) {
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
	}
	func onStoryDeliveryPreviewChanged(preview: String, node: NVDelivery) {
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
	}
}
