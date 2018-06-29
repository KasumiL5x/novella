//
//  NVReader.swift
//  NovellaModel
//
//  Created by Daniel Green on 15/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public protocol NVReaderDelegate {
	// called when the reader presents a node for reading
	func readerNodeWillConsume(node: NVNode, outputs: [NVBaseLink])
	
	// called prior to advancing a node along one of its output links
	func readerLinkWillFollow(outputs: [NVBaseLink]) -> NVBaseLink
}

public class NVReader {
	// MARK: - Variables -
	private let _manager: NVStoryManager
	private let _delegate: NVReaderDelegate
	private var _graph: NVGraph?
	private var _currentNode: NVNode?
	
	// MARK: - Initialization -
	public init(manager: NVStoryManager, delegate: NVReaderDelegate) {
		self._manager = manager
		self._delegate = delegate
		self._graph = nil
		self._currentNode = nil
	}
	
	// MARK: - Functions -
	public func start(_ graph: NVGraph, atNode: NVNode?) {
		guard let startNode = (atNode != nil ? atNode : graph._entry) as? NVNode else {
			print("NVReader::start() couldn't find a suitable start node.  Either the graph's entry must be valid, or the given node must be valid and a child of the graph.")
			return
		}
		
		_graph = graph
		_currentNode = startNode
		
		// prepare for a fresh reading
		_manager.prepareForReading()
		
		// kick everything off
		_delegate.readerNodeWillConsume(node: startNode, outputs: getNodeLinks(startNode))
	}
	
	public func next() {
		if _currentNode == nil {
			return
		}
		
		// get link from reader
		let availableLinks = getNodeLinks(_currentNode!)
		let chosenLink = _delegate.readerLinkWillFollow(outputs: availableLinks)
		
		// link must be within the links array
		if !availableLinks.contains(chosenLink) {
			print("NVReader::next() requested link wasn't in list provided.")
			return
		}
		
		var nextNode: NVNode? = nil
		switch chosenLink {
		case is NVLink:
			nextNode = (chosenLink as! NVLink).Transfer._destination as? NVNode
			
		case is NVBranch:
			let asBranch = (chosenLink as! NVBranch)
			nextNode = asBranch.PreCondition.execute() ? asBranch.TrueTransfer._destination as? NVNode : asBranch.FalseTransfer._destination as? NVNode
			
		default:
			print("NVReader::next() requested link isn't yet implemented in reading, sorry!")
			return
		}
		
		// next node can't be nil
		if nextNode == nil {
			print("NVReader::next() requested link could not be followed as its destination was nil.")
			return
		}
		
		// for now I'm not handling nodes in other graphs
		if !_graph!.contains(node: nextNode!) {
			print("NVReader::next() requested links's destination is in another graph which I'm not supporting right now.")
			return
		}
		
		// run the link's function
		switch chosenLink {
		case is NVLink:
			(chosenLink as! NVLink).Transfer.Function.execute()
			
		case is NVBranch:
			let asBranch = (chosenLink as! NVBranch)
			asBranch.Condition.execute() ? asBranch.TrueTransfer.Function.execute() : asBranch.FalseTransfer.Function.execute()
			
		default:
			print("NVReader::next() requested link isn't yet implemented in reading, sorry!")
			return
		}
		
		// update and send to user
		_currentNode = nextNode
		_delegate.readerNodeWillConsume(node: _currentNode!, outputs: getNodeLinks(_currentNode!))
	}
	
	private func getNodeLinks(_ node: NVNode) -> [NVBaseLink] {
		var links: [NVBaseLink] = []
		for x in _manager.getLinksFrom(node) {
			switch x {
			case is NVLink:
				let asLink = x as! NVLink
				if asLink.Transfer._destination != nil && asLink.PreCondition.execute() {
					links.append(x)
				}
				
			case is NVBranch:
				let asBranch = x as! NVBranch
				if asBranch.TrueTransfer._destination != nil && asBranch.FalseTransfer._destination != nil && asBranch.PreCondition.execute() {
					links.append(x)
				}
				
			default:
				print("NVReader::getNodeLinks() encountered an unhandled link.")
			}
		}
		return links
	}
}
