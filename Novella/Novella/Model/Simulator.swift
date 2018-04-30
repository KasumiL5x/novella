//
//  Simulator.swift
//  Novella
//
//  Created by Daniel Green on 29/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

protocol SimulatorController {
	// gives the controller the current available node and a list of links it can follow
	func currentNode(node: FlowNode, outputs: [BaseLink])
}

class Simulator {
	var _story: Story?
	var _controller: SimulatorController?
	var _currentNode: FlowNode?
	
	init(story: Story, controller: SimulatorController) {
		self._story = story
		self._controller = controller
		self._currentNode = nil
	}
	
	func start(graph: FlowGraph) -> Bool {
		if _controller == nil {
			return false
		}
		
		if !graph.canSimulate() {
			return false
		}
		
		_currentNode = resolveLinkable(node: graph._entry)
		_controller?.currentNode(node: _currentNode!, outputs: _story!.getLinksFrom(linkable: _currentNode!))
		
		return true
	}
	
	// controller should call this to proceed from the current node
	func proceed(link: BaseLink) throws {
		if !_story!.getLinksFrom(linkable: _currentNode!).contains(link) {
			throw Errors.invalid("Tried to progress along a link that didn't belong to the current node.")
		}
		
		var destinationUUID: String?
		
		if let asLink = link as? Link {
			destinationUUID = asLink._transfer._destination?.UUID.uuidString
		} else if let asBranch = link as? Branch {
			destinationUUID = asBranch._condition.execute() ? asBranch._trueTransfer._destination?.UUID.uuidString : asBranch._falseTransfer._destination?.UUID.uuidString
		} else if let asSwitch = link as? Switch {
			fatalError("Not yet implemented.")
		}
		
		guard let destNode = _story?.findBy(uuid: destinationUUID ?? "") as? FlowNode else {
			throw Errors.invalid("Destination node was not found or was not a FlowNode.")
		}
		
		_currentNode = resolveLinkable(node: destNode)
		_controller?.currentNode(node: _currentNode!, outputs: _story!.getLinksFrom(linkable: _currentNode!))
	}
	
	// keeps traversing flow graph entry points until the first flow node is found
	func resolveLinkable(node: Linkable?) -> FlowNode {
		if node == nil {
			fatalError("Tried to resolve a nil Linkable.")
		}
		
		// return self if it's already a flow node - the most common case
		if let flowNode = node as? FlowNode {
			return flowNode
		}
		
		// for the cases where an entry point is also a graph, we need to resolve the entry until we get a node
		if let flowGraph = node as? FlowGraph {
			// entry is a node - return it
			if let entry = flowGraph._entry as? FlowNode {
				return entry
			}
			
			if flowGraph._entry == nil {
				fatalError("Traversing FlowGraphs' entry points resulted in a graph; it must end in a FlowNode.")
			}
			
			// otherwise keep processing
			return resolveLinkable(node: flowGraph._entry!)
		}
		
		fatalError("Could not resolve Linkable.")
	}
}