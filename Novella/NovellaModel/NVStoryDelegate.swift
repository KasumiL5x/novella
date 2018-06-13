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
	// Called when an NVFolder is created using StoryManager.makeFolder().
	func onStoryMakeFolder(folder: NVFolder)
	// Called when an NVVariable is created using StoryManager.makeVariable().
	func onStoryMakeVariable(variable: NVVariable)
	// Called when an NVGraph is created using StoryManager.makeGraph().
	func onStoryMakeGraph(graph: NVGraph)
	// Called when an NVLink is created using StoryManager.makeLink().
	func onStoryMakeLink(link: NVLink)
	// Called when an NVBranch is created using StoryManager.makeBranch().
	func onStoryMakeBranch(branch: NVBranch)
	// Called when an NVSwitch is created using StoryManager.makeSwitch().
	func onStoryMakeSwitch(switch: NVSwitch)
	// Called when an NVDialog is created using StoryManager.makeDialog().
	func onStoryMakeDialog(dialog: NVDialog)
	// Called when an NVDelivery is created using StoryManager.makeDelivery().
	func onStoryMakeDelivery(delivery: NVDelivery)
	// Called when a NVContext is created using StoryManager.makeContext().
	func onStoryMakeContext(context: NVContext)
	
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint)
	
	// Called when a NVTrashable is added to the trash using the internal StoryManager.trash().
	func onStoryTrashItem(item: NVObject)
	// Called when a NVTrashable is removed from the trash using the internal StoryManager().
	func onStoryUntrashItem(item: NVObject)
	
	// Called when an NVFolder is deleted using StoryManager.deleteFolder().
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool)
	// Called when an NVVariable is deleted using StoryManager.deleteVariable().
	func onStoryDeleteVariable(variable: NVVariable)
	// Called when an NVNode is deleted using StoryManager.delete(node).
	func onStoryDeleteNode(node: NVNode)
	// Called when an NVBaseLink is deleted using StoryManager.delete(link).
	func onStoryDeleteLink(link: NVBaseLink)
	
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
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph)
	
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
	
	// Called when an NVLink's transfer's destination is set using NVLink.SetDestination().
	func onStoryLinkSetDestination(link: NVLink, dest: NVObject?)
	// Called when an NVBranch's true transfer's destination is set using NVBranch.SetTrueDestination().
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVObject?)
	// Called when an NVBranch's false transfer's destination is set using NVBranch.SetTrueDestination().
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVObject?)
	
	// Called when an NVVariable's name is changed using NVVariable.Name.
	func onStoryVariableNameChanged(variable: NVVariable, name: String)
	// Called when an NVVariable's synopsis is changed using NVVariable.Synopsis.
	func onStoryVariableSynopsisChanged(variable: NVVariable, synopsis: String)
	// Called when an NVVariable's type is changed using NVVariable.setType().
	func onStoryVariableTypeChanged(variable: NVVariable, type: NVDataType)
	// Called when an NVVariable's value is changed using NVVariable.setValue().
	func onStoryVariableValueChanged(variable: NVVariable, value: Any)
	// Called when an NVVariable's initial value is changed using NVVariable.setInitialValue().
	func onStoryVariableInitialValueChanged(variable: NVVariable, value: Any)
	// Called when an NVVariable's constant is changed using NVVariable.Constant.
	func onStoryVariableConstantChanged(variable: NVVariable, constant: Bool)
	
	// Called when an NVFolder's name is changed using NVFolder.Name.
	func onStoryFolderNameChanged(folder: NVFolder, name: String)
	// Called when an NVFolder's synopsis is changed using NVFolder.Synopsis.
	func onStoryFolderSynopsisChanged(folder: NVFolder, synopsis: String)
	// Called when an NVFolder is added to an NVFolder as a child.
	func onStoryFolderAddFolder(parent: NVFolder, child: NVFolder)
	// Called when an NVFolder is removed from an NVFolder as a child.
	func onStoryFolderRemoveFolder(parent: NVFolder, child: NVFolder)
	// Called when an NVVariable is added to an NVFolder as a child.
	func onStoryFolderAddVariable(parent: NVFolder, child: NVVariable)
	// Called when an NVVariable is removed from an NVFolder as a child.
	func onStoryFolderRemoveVariable(parent: NVFolder, child: NVVariable)
	
	// Called when an NVStory's name is changed using NVStory.Name.
	func onStoryNameChanged(story: NVStory, name: String)
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
	func onStoryMakeContext(context: NVContext) {
	}
	
	func onStoryObjectPositionChanged(obj: NVObject, oldPos: CGPoint, newPos: CGPoint) {
	}
	
	func onStoryTrashItem(item: NVObject) {
	}
	func onStoryUntrashItem(item: NVObject) {
	}
	
	func onStoryDeleteFolder(folder: NVFolder, contents: Bool) {
	}
	func onStoryDeleteVariable(variable: NVVariable) {
	}
	func onStoryDeleteNode(node: NVNode) {
	}
	func onStoryDeleteLink(link: NVBaseLink) {
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
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
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
	
	func onStoryLinkSetDestination(link: NVLink, dest: NVObject?) {
	}
	func onStoryBranchSetTrueDestination(branch: NVBranch, dest: NVObject?) {
	}
	func onStoryBranchSetFalseDestination(branch: NVBranch, dest: NVObject?) {
	}
	
	func onStoryVariableNameChanged(variable: NVVariable, name: String) {
	}
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
	
	func onStoryFolderNameChanged(folder: NVFolder, name: String) {
	}
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
	
	func onStoryNameChanged(story: NVStory, name: String) {
	}
}
