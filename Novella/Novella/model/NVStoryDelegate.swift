//
//  NVStoryDelegate.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

protocol NVStoryDelegate {
	// MARK: Variables
	func nvVariableDidRename(variable: NVVariable)
	func nvVariableSynopsisDidChange(variable: NVVariable)
	func nvVariableConstantDidChange(variable: NVVariable)
	func nvVariableValueDidChange(variable: NVVariable)
	func nvVariableInitialValueDidChange(variable: NVVariable)
	
	// MARK: Folders
	func nvFolderDidRename(folder: NVFolder)
	func nvFolderSynopsisDidChange(folder: NVFolder)
	func nvFolderDidAddFolder(parent: NVFolder, child: NVFolder)
	func nvFolderDidRemoveFolder(parent: NVFolder, child: NVFolder)
	func nvFolderDidAddVariable(parent: NVFolder, child: NVVariable)
	func nvFolderDidRemoveVariable(parent: NVFolder, child: NVVariable)
	
	// MARK: Transfers
	func nvTransferDestinationDidSet(transfer: NVTransfer)
	
	// MARK: Creation
	func nvStoryDidCreateGraph(graph: NVGraph)
	func nvStoryDidCreateFolder(folder: NVFolder)
	func nvStoryDidCreateLink(link: NVLink)
	func nvStoryDidCreateBranch(branch: NVBranch)
	func nvStoryDidCreateSwitch(swtch: NVSwitch)
	func nvStoryDidCreateDialog(dialog: NVDialog)
	func nvStoryDidCreateDelivery(delivery: NVDelivery)
	func nvStoryDidCreateContext(context: NVContext)
	func nvStoryDidCreateEntity(entity: NVEntity)
	func nvStoryDidCreateVariable(variable: NVVariable)
	
	// MARK: Deletion
	func nvStoryDidDeleteFolder(folder: NVFolder)
	func nvStoryDidDeleteVariable(variable: NVVariable)
	func nvStoryDidDeleteEntity(entity: NVEntity)
	func nvStoryDidDeleteNode(node: NVNode)
	func nvStoryDidDeleteLink(link: NVLink)
	func nvStoryDidDeleteBranch(branch: NVBranch)
	func nvStoryDidDeleteSwitch(swtch: NVSwitch)
	func nvStoryDidDeleteGraph(graph: NVGraph)
	
	// MARK: Graphs
	func nvGraphDidRename(graph: NVGraph)
	func nvGraphDidAddGraph(parent: NVGraph, child: NVGraph)
	func nvGraphDidRemoveGraph(parent: NVGraph, child: NVGraph)
	func nvGraphDidAddNode(parent: NVGraph, child: NVNode)
	func nvGraphDidRemoveNode(parent: NVGraph, child: NVNode)
	func nvGraphDidSetEntry(graph: NVGraph, entry: NVNode?)
	func nvGraphDidAddLink(graph: NVGraph, link: NVLink)
	func nvGraphDidRemoveLink(graph: NVGraph, link: NVLink)
	func nvGraphDidAddBranch(graph: NVGraph, branch: NVBranch)
	func nvGraphDidRemoveBranch(graph: NVGraph, branch: NVBranch)
	func nvGraphDidAddSwitch(graph: NVGraph, swtch: NVSwitch)
	func nvGraphDidRemoveSwitch(graph: NVGraph, swtch: NVSwitch)
	
	// MARK: Nodes
	func nvNodeDidRename(node: NVNode)
	
	// MARK: Dialogs
	func nvDialogContentDidChange(dialog: NVDialog)
	func nvDialogDirectionsDidChange(dialog: NVDialog)
	func nvDialogPreviewDidChange(dialog: NVDialog)
	func nvDialogInstigatorDidChange(dialog: NVDialog)
	
	// MARK: Deliveries
	func nvDeliveryContentDidChange(delivery: NVDelivery)
	func nvDeliveryDirectionsDidChange(delivery: NVDelivery)
	func nvDeliveryPreviewDidChange(delivery: NVDelivery)
	
	// MARK: Contexts
	func nvContextContentDidChange(context: NVContext)
	
	// MARK: Conditions
	func nvConditionDidUpdate(condition: NVCondition)
	
	// MARK: Functions
	func nvFunctionDidUpdate(function: NVFunction)
	
	// MARK: Switches
	func nvSwitchVariableDidChange(swtch: NVSwitch)
	func nvSwitchDidAddOption(swtch: NVSwitch, option: NVSwitchOption)
	func nvSwitchDidRemoveOption(swtch: NVSwitch, option: NVSwitchOption)
	
	// MARK: Entities
	func nvEntityDidRename(entity: NVEntity)
	func nvEntitySynopsisDidChange(entity: NVEntity)
}

// MARK: - Default Implementations
extension NVStoryDelegate {
	// MARK: Variables
	func nvVariableDidRename(variable: NVVariable) {
	}
	func nvVariableSynopsisDidChange(variable: NVVariable) {
	}
	func nvVariableConstantDidChange(variable: NVVariable) {
	}
	func nvVariableValueDidChange(variable: NVVariable) {
	}
	func nvVariableInitialValueDidChange(variable: NVVariable) {
	}
	
	// MARK: Folders
	func nvFolderDidRename(folder: NVFolder) {
	}
	func nvFolderSynopsisDidChange(folder: NVFolder) {
	}
	func nvFolderDidAddFolder(parent: NVFolder, child: NVFolder) {
	}
	func nvFolderDidRemoveFolder(parent: NVFolder, child: NVFolder) {
	}
	func nvFolderDidAddVariable(parent: NVFolder, child: NVVariable) {
	}
	func nvFolderDidRemoveVariable(parent: NVFolder, child: NVVariable) {
	}
	
	// MARK: Transfers
	func nvTransferDestinationDidSet(transfer: NVTransfer) {
	}
	
	// MARK: Creation
	func nvStoryDidCreateGraph(graph: NVGraph) {
	}
	func nvStoryDidCreateFolder(folder: NVFolder) {
	}
	func nvStoryDidCreateLink(link: NVLink) {
	}
	func nvStoryDidCreateBranch(branch: NVBranch) {
	}
	func nvStoryDidCreateSwitch(swtch: NVSwitch) {
	}
	func nvStoryDidCreateDialog(dialog: NVDialog) {
	}
	func nvStoryDidCreateDelivery(delivery: NVDelivery) {
	}
	func nvStoryDidCreateContext(context: NVContext) {
	}
	func nvStoryDidCreateEntity(entity: NVEntity) {
	}
	func nvStoryDidCreateVariable(variable: NVVariable) {
	}
	
	// MARK: - Deletion
	func nvStoryDidDeleteFolder(folder: NVFolder) {
	}
	func nvStoryDidDeleteVariable(variable: NVVariable) {
	}
	func nvStoryDidDeleteEntity(entity: NVEntity) {
	}
	func nvStoryDidDeleteNode(node: NVNode) {
	}
	func nvStoryDidDeleteLink(link: NVLink) {
	}
	func nvStoryDidDeleteBranch(branch: NVBranch) {
	}
	func nvStoryDidDeleteSwitch(swtch: NVSwitch) {
	}
	func nvStoryDidDeleteGraph(graph: NVGraph) {
	}
	
	// MARK: Graphs
	func nvGraphDidRename(graph: NVGraph) {
	}
	func nvGraphDidAddGraph(parent: NVGraph, child: NVGraph) {
	}
	func nvGraphDidRemoveGraph(parent: NVGraph, child: NVGraph) {
	}
	func nvGraphDidAddNode(parent: NVGraph, child: NVNode) {
	}
	func nvGraphDidRemoveNode(parent: NVGraph, child: NVNode) {
	}
	func nvGraphDidSetEntry(graph: NVGraph, entry: NVNode?) {
	}
	func nvGraphDidAddLink(graph: NVGraph, link: NVLink) {
	}
	func nvGraphDidRemoveLink(graph: NVGraph, link: NVLink) {
	}
	func nvGraphDidAddBranch(graph: NVGraph, branch: NVBranch) {
	}
	func nvGraphDidRemoveBranch(graph: NVGraph, branch: NVBranch) {
	}
	func nvGraphDidAddSwitch(graph: NVGraph, swtch: NVSwitch) {
	}
	func nvGraphDidRemoveSwitch(graph: NVGraph, swtch: NVSwitch) {
	}
	
	// MARK: Nodes
	func nvNodeDidRename(node: NVNode) {
	}
	
	// MARK: Dialogs
	func nvDialogContentDidChange(dialog: NVDialog) {
	}
	func nvDialogDirectionsDidChange(dialog: NVDialog) {
	}
	func nvDialogPreviewDidChange(dialog: NVDialog) {
	}
	func nvDialogInstigatorDidChange(dialog: NVDialog) {
	}
	
	// MARK: Deliveries
	func nvDeliveryContentDidChange(delivery: NVDelivery) {
	}
	func nvDeliveryDirectionsDidChange(delivery: NVDelivery) {
	}
	func nvDeliveryPreviewDidChange(delivery: NVDelivery) {
	}
	
	// MARK: Contexts
	func nvContextContentDidChange(context: NVContext) {
	}
	
	// MARK: Conditions
	func nvConditionDidUpdate(condition: NVCondition) {
	}
	
	// MARK: Functions
	func nvFunctionDidUpdate(function: NVFunction) {
	}
	
	// MARK: Switches
	func nvSwitchVariableDidChange(swtch: NVSwitch) {
	}
	func nvSwitchDidAddOption(swtch: NVSwitch, option: NVSwitchOption) {
	}
	func nvSwitchDidRemoveOption(swtch: NVSwitch, option: NVSwitchOption) {
	}
	
	// MARK: Entities
	func nvEntityDidRename(entity: NVEntity) {
	}
	func nvEntitySynopsisDidChange(entity: NVEntity) {
	}
}
