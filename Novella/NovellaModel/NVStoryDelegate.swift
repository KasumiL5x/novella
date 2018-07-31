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
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph)
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph)
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph)
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph)
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
	
	// MARK: Transfers
	func onStoryTransferDestinationChanged(transfer: NVTransfer, dest: NVObject?)
	
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
	}
	func onStoryMakeVariable(variable: NVVariable) {
	}
	func onStoryMakeGraph(graph: NVGraph) {
	}
	func onStoryMakeLink(link: NVLink) {
	}
	func onStoryMakeBranch(branch: NVBranch) {
	}
	func onStoryMakeSwitch(theSwitch: NVSwitch) {
	}
	func onStoryMakeDialog(dialog: NVDialog) {
	}
	func onStoryMakeEntity(entity: NVEntity) {
	}
	func onStoryMakeDelivery(delivery: NVDelivery) {
	}
	func onStoryMakeContext(context: NVContext) {
	}
	
	// MARK: Deletion
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool) {
	}
	func onStoryDeleteVariable(variable: NVVariable) {
	}
	func onStoryDeleteNode(node: NVNode) {
	}
	func onStoryDeleteLink(link: NVBaseLink) {
	}
	func onStoryDeleteGraph(graph: NVGraph) {
	}
	func onStoryDeleteEntity(entity: NVEntity) {
	}
	
	// MARK: Objects
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint) {
//		NVLog.log("Object (\(obj.UUID)) moved from (\(oldPos)) to (\(newPos)).", level: .verbose)
	}
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String) {
	}
	func onStoryTrashObject(object: NVObject) {
	}
	func onStoryUntrashObject(object: NVObject) {
	}
	
	// MARK: Story
	func onStoryNameChanged(story: NVStory, name: String) {
	}
	func onStoryAddFolder(folder: NVFolder) {
	}
	func onStoryRemoveFolder(folder: NVFolder) {
	}
	func onStoryAddGraph(graph: NVGraph) {
	}
	func onStoryRemoveGraph(graph: NVGraph) {
	}
	
	// MARK: Graphs
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
	}
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
	}
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
	}
	func onStoryGraphAddListener(listener: NVListener, parent: NVGraph) {
	}
	func onStoryGraphRemoveGraph(graph: NVGraph, from: NVGraph) {
	}
	func onStoryGraphRemoveNode(node: NVNode, from: NVGraph) {
		
	}
	func onStoryGraphRemoveLink(link: NVBaseLink, from: NVGraph) {
	}
	func onStoryGraphRemoveListener(listener: NVListener, from: NVGraph) {
	}
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
	}
	
	// MARK: Nodes
	func onStoryNodePreviewChanged(preview: String, node: NVNode) {
	}
	func onStoryNodeSizeChanged(node: NVNode) {
	}
	
	// MARK: Dialogs
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
	}
	func onStoryDialogDirectionsChanged(directions: String, node: NVDialog) {
	}
	func onStoryDialogSpeakerChanged(speaker: NVEntity?, node: NVDialog) {
	}
	
	// MARK: Deliveries
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
	}
	func onStoryDeliveryDirectionsChanged(directions: String, node: NVDelivery) {
	}
	
	// MARK: Transfers
	func onStoryTransferDestinationChanged(transfer: NVTransfer, dest: NVObject?) {
	}
	
	// MARK: Entities
	func onStoryEntityImageChanged(entity: NVEntity) {
	}
	
	// MARK: Functions/Conditions
	func onStoryFunctionUpdated(function: NVFunction) {
	}
	func onStoryConditionUpdated(condition: NVCondition) {
	}
	
	// MARK: Variables
	func onStoryVariableSynopsisChanged(variable: NVVariable, synopsis: String) {
	}
	func onStoryVariableTypeChanged(variable: NVVariable, type: NVDataType) {
	}
	func onStoryVariableValueChanged(variable: NVVariable, value: Any) {
	}
	func onStoryVariableInitialValueChanged(variable: NVVariable, value: Any) {
	}
	func onStoryVariableConstantChanged(variable: NVVariable, constant: Bool) {
	}

	// MARK: Folders
	func onStoryFolderSynopsisChanged(folder: NVFolder, synopsis: String) {
	}
	func onStoryFolderAddFolder(parent: NVFolder, child: NVFolder) {
	}
	func onStoryFolderRemoveFolder(parent: NVFolder, child: NVFolder) {
	}
	func onStoryFolderAddVariable(parent: NVFolder, child: NVVariable) {
	}
	func onStoryFolderRemoveVariable(parent: NVFolder, child: NVVariable) {
	}
}
