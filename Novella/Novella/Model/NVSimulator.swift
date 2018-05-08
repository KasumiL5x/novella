//
//  NVSimulator.swift
//  Novella
//
//  Created by Daniel Green on 29/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

protocol NVSimulatorController {
	// gives the controller the current available node and a list of links it can follow
	func currentNode(node: NVNode, outputs: [NVBaseLink])
}

class NVSimulator {
	var _story: NVStory?
	var _controller: NVSimulatorController?
	var _currentNode: NVNode?
	
	init(story: NVStory, controller: NVSimulatorController) {
		self._story = story
		self._controller = controller
		self._currentNode = nil
	}
	
	func start(_ graph: NVGraph) -> Bool {
		if _controller == nil {
			return false
		}
		
		if !graph.canSimulate() {
			return false
		}
		
		_currentNode = resolveLinkable(graph._entry)
		_controller?.currentNode(node: _currentNode!, outputs: _story!.getLinksFrom(_currentNode!))
		
		return true
	}
	
	// controller should call this to proceed from the current node
	func proceed(_ link: NVBaseLink) throws {
		if !_story!.getLinksFrom(_currentNode!).contains(link) {
			throw NVError.invalid("Tried to progress along a link that didn't belong to the current node.")
		}
		
		var destinationUUID: String?
		
		if let asLink = link as? NVLink {
			destinationUUID = asLink._transfer._destination?.UUID.uuidString
		} else if let asBranch = link as? NVBranch {
			destinationUUID = asBranch._condition.execute() ? asBranch._trueTransfer._destination?.UUID.uuidString : asBranch._falseTransfer._destination?.UUID.uuidString
		} else if let asSwitch = link as? NVSwitch {
			fatalError("Not yet implemented.")
		}
		
		guard let destNode = _story?.findBy(uuid: destinationUUID ?? "") as? NVNode else {
			throw NVError.invalid("Destination node was not found or was not a Node.")
		}
		
		_currentNode = resolveLinkable(destNode)
		_controller?.currentNode(node: _currentNode!, outputs: _story!.getLinksFrom(_currentNode!))
	}
	
	// keeps traversing graph entry points until the first node is found
	func resolveLinkable(_ linkable: NVLinkable?) -> NVNode {
		if linkable == nil {
			fatalError("Tried to resolve a nil Linkable.")
		}
		
		// return self if it's already a node - the most common case
		if let asNode = linkable as? NVNode {
			return asNode
		}
		
		// for the cases where an entry point is also a graph, we need to resolve the entry until we get a node
		if let asGraph = linkable as? NVGraph {
			// entry is a node - return it
			if let entry = asGraph._entry as? NVNode {
				return entry
			}
			
			if asGraph._entry == nil {
				fatalError("Traversing Graphs' entry points resulted in a graph; it must end in a Node.")
			}
			
			// otherwise keep processing
			return resolveLinkable(asGraph._entry!)
		}
		
		fatalError("Could not resolve Linkable.")
	}
}
