//
//  NVStory+Delegate.swift
//  NovellaModel
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

// MARK: - Main Delegate -
public protocol NVStoryDelegate {
	// MARK: Creation
	func onStoryMakeFolder(folder: NVFolder)
	func onStoryMakeVariable(variable: NVVariable)
	func onStoryMakeGraph(graph: NVGraph)
	func onStoryMakeLink(link: NVLink)
	func onStoryMakeBranch(branch: NVBranch)
	func onStoryMakeSwitch(theSwitch: NVSwitch)
	func onStoryMakeDialog(dialog: NVDialog)
	func onStoryMakeEntity(entity: NVEntity)
	func onStoryMakeDelivery(delivery: NVDelivery)
	func onStoryMakeContext(context: NVContext)
	
	// MARK: Deletion
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool)
	func onStoryDeleteVariable(variable: NVVariable)
	func onStoryDeleteNode(node: NVNode)
	func onStoryDeleteLink(link: NVBaseLink)
	func onStoryDeleteGraph(graph: NVGraph)
	func onStoryDeleteEntity(entity: NVEntity)
	
	// MARK: Objects
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint)
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String)
	func onStoryTrashObject(object: NVObject)
	func onStoryUntrashObject(object: NVObject)
	
	// MARK: Story
	func onStoryNameChanged(story: NVStory, name: String)
	func onStoryAddFolder(folder: NVFolder)
	func onStoryRemoveFolder(folder: NVFolder)
	func onStoryAddGraph(graph: NVGraph)
	func onStoryRemoveGraph(graph: NVGraph)
	
	// MARK: Graphs
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph)
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph)
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph)
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph)
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph)
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph)
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph)
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph)
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph)
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph)
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph)
	
	// MARK: Nodes
	func onStoryNodePreviewChanged(preview: String, node: NVNode)
	func onStoryNodeSizeChanged(node: NVNode)
	
	// MARK: Dialogs
	func onStoryDialogContentChanged(content: String, node: NVDialog)
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog)
	func onStoryDialogSpeakerChanged(speaker: NVEntity?, node: NVDialog)
	
	// MARK: Deliveries
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery)
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery)
	
	// MARK: Links
	func onStoryLinkSetDestination(link: NVLink, dest: NVObject?)
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVObject?)
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVObject?)
	
	// MARK: Entities
	func onStoryEntityImageChanged(entity: NVEntity)
	
	// MARK: Functions/Conditions
	func onStoryFunctionUpdated(function: NVFunction)
	func onStoryConditionUpdated(condition: NVCondition)
	
	// MARK: Variables
	func onStoryVariableSynopsisChanged(variable: NVVariable, synopsis: String)
	func onStoryVariableTypeChanged(variable: NVVariable, type: NVDataType)
	func onStoryVariableValueChanged(variable: NVVariable, value: Any)
	func onStoryVariableInitialValueChanged(variable: NVVariable, value: Any)
	func onStoryVariableConstantChanged(variable: NVVariable, constant: Bool)
	
	// MARK: Folders
	func onStoryFolderSynopsisChanged(folder: NVFolder, synopsis: String)
	func onStoryFolderAddFolder(parent: NVFolder, child: NVFolder)
	func onStoryFolderRemoveFolder(parent: NVFolder, child: NVFolder)
	func onStoryFolderAddVariable(parent: NVFolder, child: NVVariable)
	func onStoryFolderRemoveVariable(parent: NVFolder, child: NVVariable)
}

// MARK: - Default Implementations -
public extension NVStoryDelegate {
	// MARK: Creation
	func onStoryMakeFolder(folder: NVFolder) {
		NVLog.log("Created a new Folder (\(folder.UUID)).", level: .simple)
	}
	func onStoryMakeVariable(variable: NVVariable) {
		NVLog.log("Created a new Variable (\(variable.UUID)).", level: .simple)
	}
	func onStoryMakeGraph(graph: NVGraph) {
		NVLog.log("Created a new Graph (\(graph.UUID)).", level: .simple)
	}
	func onStoryMakeLink(link: NVLink) {
		NVLog.log("Created a new Link (\(link.UUID)).", level: .simple)
	}
	func onStoryMakeBranch(branch: NVBranch) {
		NVLog.log("Created a new Branch (\(branch.UUID)).", level: .simple)
	}
	func onStoryMakeSwitch(theSwitch: NVSwitch) {
		NVLog.log("Created a new Switch (\(theSwitch.UUID)).", level: .simple)
	}
	func onStoryMakeDialog(dialog: NVDialog) {
		NVLog.log("Created a new Dialog (\(dialog.UUID)).", level: .simple)
	}
	func onStoryMakeEntity(entity: NVEntity) {
		NVLog.log("Created a new Entity (\(entity.UUID)).", level: .simple)
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
		NVLog.log("Created a new Delivery (\(delivery.UUID)).", level: .simple)
	}
	func onStoryMakeContext(context: NVContext) {
		NVLog.log("Created a new Context (\(context.UUID)).", level: .simple)
	}
	
	// MARK: Deletion
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool) {
		NVLog.log("Deleted Folder (\(folder.UUID))" + (contents ? " and its contents." : "."), level: .simple)
	}
	func onStoryDeleteVariable(variable: NVVariable) {
		NVLog.log("Deleted Variable (\(variable.UUID)).", level: .simple)
	}
	func onStoryDeleteNode(node: NVNode) {
		NVLog.log("Deleted Node (\(node.UUID)).", level: .simple)
	}
	func onStoryDeleteLink(link: NVBaseLink) {
		NVLog.log("Deleted Link (\(link.UUID)).", level: .simple)
	}
	func onStoryDeleteGraph(graph: NVGraph) {
		NVLog.log("Deleted Graph (\(graph.UUID)).", level: .simple)
	}
	func onStoryDeleteEntity(entity: NVEntity) {
		NVLog.log("Deleted Entity (\(entity.UUID)).", level: .simple)
	}
	
	// MARK: Objects
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint) {
//		NVLog.log("Object (\(obj.UUID)) moved from (\(oldPos)) to (\(newPos)).", level: .verbose)
	}
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String) {
		NVLog.log("Object (\(obj.UUID)) renamed from (\(oldName)) to (\(newName)).", level: .simple)
	}
	func onStoryTrashObject(object: NVObject) {
		NVLog.log("Object (\(object.UUID)) trashed.", level: .simple)
	}
	func onStoryUntrashObject(object: NVObject) {
		NVLog.log("Object (\(object.UUID)) untrashed.", level: .simple)
	}
	
	// MARK: Story
	func onStoryNameChanged(story: NVStory, name: String) {
		NVLog.log("Story name changed to (\(name)).", level: .simple)
	}
	func onStoryAddFolder(folder: NVFolder) {
		NVLog.log("Folder (\(folder.UUID)) added to Story.", level: .simple)
	}
	func onStoryRemoveFolder(folder: NVFolder) {
		NVLog.log("Folder (\(folder.UUID)) removed from Story.", level: .simple)
	}
	func onStoryAddGraph(graph: NVGraph) {
		NVLog.log("Graph (\(graph.UUID)) added to Story.", level: .simple)
	}
	func onStoryRemoveGraph(graph: NVGraph) {
		NVLog.log("Graph (\(graph.UUID)) removed from Story.", level: .simple)
	}
	
	// MARK: Graphs
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
		NVLog.log("Graph (\(graph.UUID)) added to Graph (\(parent.UUID)).", level: .simple)
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
		NVLog.log("Node (\(node.UUID)) added to Graph (\(parent.UUID)).", level: .simple)
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
		NVLog.log("Link (\(link.UUID)) added to Graph (\(parent.UUID)).", level: .simple)
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
		NVLog.log("Listener (\(listener.UUID)) added to Graph (\(parent.UUID)).", level: .simple)
	}
	func onStoryGraphAddExit(exit: NVExitNode, parent: NVGraph) {
		NVLog.log("Exit (\(exit.UUID)) added to Graph (\(parent.UUID)).", level: .simple)
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
		NVLog.log("Graph (\(graph.UUID)) removed from Graph (\(from.UUID)).", level: .simple)
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
		NVLog.log("Node (\(node.UUID)) removed from Graph (\(from.UUID)).", level: .simple)
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
		NVLog.log("Link (\(link.UUID)) removed from Graph (\(from.UUID)).", level: .simple)
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
		NVLog.log("Listener (\(listener.UUID)) removed from Graph (\(from.UUID)).", level: .simple)
	}
	func onStoryGraphRemoveExit(exit: NVExitNode, from: NVGraph) {
		NVLog.log("Exit (\(exit.UUID)) removed from Graph (\(from.UUID)).", level: .simple)
	}
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
		NVLog.log("Graph (\(graph.UUID)) Entry set to (\(entry.UUID)).", level: .simple)
	}
	
	// MARK: Nodes
	func onStoryNodePreviewChanged(preview: String, node: NVNode) {
		NVLog.log("Node (\(node.UUID)) preview set to (\(preview)).", level: .simple)
	}
	func onStoryNodeSizeChanged(node: NVNode) {
		NVLog.log("Node (\(node.UUID)) size set to (\(node.Size)).", level: .simple)
	}
	
	// MARK: Dialogs
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		NVLog.log("Dialog (\(node.UUID)) content set to (\(content)).", level: .simple)
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
		NVLog.log("Dialog (\(node.UUID)) directions set to (\(directions)).", level: .simple)
	}
	func onStoryDialogSpeakerChanged(speaker: NVEntity?, node: NVDialog) {
		NVLog.log("Dialog (\(node.UUID)) speaker set to (\(speaker?.UUID.uuidString ?? "nil")).", level: .simple)
	}
	
	// MARK: Deliveries
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		NVLog.log("Delivery (\(node.UUID)) content set to (\(content)).", level: .simple)
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
		NVLog.log("Delivery (\(node.UUID)) directions set to (\(directions)).", level: .simple)
	}
	
	// MARK: Links
	func onStoryLinkSetDestination(link: NVLink, dest: NVObject?) {
		NVLog.log("Link (\(link.UUID)) destination set to (\(dest?.UUID.uuidString ?? "nil")).", level: .simple)
	}
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVObject?) {
		NVLog.log("Branch (\(branch.UUID)) true destination set to (\(dest?.UUID.uuidString ?? "nil")).", level: .simple)
	}
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVObject?) {
		NVLog.log("Branch (\(branch.UUID)) false destination set to (\(dest?.UUID.uuidString ?? "nil")).", level: .simple)
	}
	
	// MARK: Entities
	func onStoryEntityImageChanged(entity: NVEntity) {
		NVLog.log("Entity (\(entity.UUID)) image changed to (\(entity.ImageName)).", level: .simple)
	}
	
	// MARK: Functions/Conditions
	func onStoryFunctionUpdated(function: NVFunction) {
		NVLog.log("Function updated.", level: .simple)
	}
	func onStoryConditionUpdated(condition: NVCondition) {
		NVLog.log("Condition updated.", level: .simple)
	}
	
	// MARK: Variables
	func onStoryVariableSynopsisChanged(variable: NVVariable, synopsis: String) {
		NVLog.log("Variable (\(variable.UUID)) synopsis set to (\(synopsis)).", level: .simple)
	}
	func onStoryVariableTypeChanged(variable: NVVariable, type: NVDataType) {
		NVLog.log("Variable (\(variable.UUID)) type set to (\(type)).", level: .simple)
	}
	func onStoryVariableValueChanged(variable: NVVariable, value: Any) {
		NVLog.log("Variable (\(variable.UUID)) value set to (\(value)).", level: .simple)
	}
	func onStoryVariableInitialValueChanged(variable: NVVariable, value: Any) {
		NVLog.log("Variable (\(variable.UUID)) initial value set to (\(value)).", level: .simple)
	}
	func onStoryVariableConstantChanged(variable: NVVariable, constant: Bool) {
		NVLog.log("Variable (\(variable.UUID)) constant set to (\(constant)).", level: .simple)
	}

	// MARK: Folders
	func onStoryFolderSynopsisChanged(folder: NVFolder, synopsis: String) {
		NVLog.log("Folder (\(folder.UUID)) synopsis set to (\(synopsis)).", level: .simple)
	}
	func onStoryFolderAddFolder(parent: NVFolder, child: NVFolder) {
		NVLog.log("Folder (\(child.UUID)) added to Folder (\(parent.UUID)).", level: .simple)
	}
	func onStoryFolderRemoveFolder(parent: NVFolder, child: NVFolder) {
		NVLog.log("Folder (\(child.UUID)) removed from (\(parent.UUID)).", level: .simple)
	}
	func onStoryFolderAddVariable(parent: NVFolder, child: NVVariable) {
		NVLog.log("Variable (\(child.UUID)) added to Folder (\(parent.UUID)).", level: .simple)
	}
	func onStoryFolderRemoveVariable(parent: NVFolder, child: NVVariable) {
		NVLog.log("Variable (\(child.UUID)) removed from Folder (\(parent.UUID)).", level: .simple)
	}
}
