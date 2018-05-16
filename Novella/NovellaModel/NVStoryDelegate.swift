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
}
