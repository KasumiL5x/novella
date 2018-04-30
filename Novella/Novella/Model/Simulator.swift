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
		
		// TODO: Technically the entry point can be another graph, but i should somehow add a constraint to resolve it to a node eventually?
		_currentNode = graph._entry as! FlowNode
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
			// TODO: Again, handle graphs (by taking their entry point; see above)
			throw Errors.invalid("Destination node was not found or was not a FlowNode.")
		}
		
		_currentNode = destNode
		_controller?.currentNode(node: _currentNode!, outputs: _story!.getLinksFrom(linkable: _currentNode!))
	}
}
