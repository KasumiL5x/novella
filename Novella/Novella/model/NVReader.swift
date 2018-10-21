//
//  NVReader.swift
//  novella
//
//  Created by Daniel Green on 05/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

protocol NVReaderDelegate {
	// called when the reader presents a node for reading
	func readerNodeWillConsume(node: NVNode, outputs: [NVTransfer])
	
	// called prior to advancing a node along one of its output links
	func readerLinkWillFollow(outputs: [NVTransfer]) -> NVTransfer
}

class NVReader {
	// MARK: - Variables
	private let _story: NVStory
	private let _delegate: NVReaderDelegate
	private var _graph: NVGraph?
	private var _currNode: NVNode?
	
	// MARK: - Initialization
	init(story: NVStory, delegate: NVReaderDelegate) {
		self._story = story
		self._delegate = delegate
		self._graph = nil
		self._currNode = nil
	}
	
	// MARK: - Functions
	func read(graph: NVGraph, at: NVNode?) {
		guard let startNode = (at != nil ? at : graph.Entry) else {
			NVLog.log("Reader couldn't find a suitable starting node. The provided node and graph's entry may be invalid.", level: .warning)
			return
		}
		
		_graph = graph
		_currNode = startNode
		
		_story.prepareForReading()
		
		_delegate.readerNodeWillConsume(node: startNode, outputs: getNodeTransfers(startNode))
	}
	
	func next() {
		guard let currNode = _currNode else {
			return
		}
		
		// get transfer from user
		let userTransfer = _delegate.readerLinkWillFollow(outputs: getNodeTransfers(currNode))
		guard let result = resolveTransfer(userTransfer) else {
			NVLog.log("Could not resolve transfer chosen by user.", level: .warning)
			return
		}
		
		// update and continue
		_currNode = result
		_delegate.readerNodeWillConsume(node: result, outputs: getNodeTransfers(result))
	}
	
	private func resolveTransfer(_ transfer: NVTransfer) -> NVNode? {
		guard let dest = transfer.Destination else {
			return nil
		}
		
		// run this transfer's function
		transfer.Function.evaluate()
		
		switch dest {
		case let asNode as NVNode: // direct as a node
			return asNode
			
		case let asBranch as NVBranch: // resolve branch
			if let result = resolveTransfer(asBranch.evaluate()) {
				return result
			}
			
		case let asSwitch as NVSwitch: // resolve switch
			if let result = resolveTransfer(asSwitch.evaluate()) {
				return result
			}
			
		default:
			return nil
		}
		
		return nil
	}
	
	private func getNodeTransfers(_ node: NVNode) -> [NVTransfer] {
		var xfers: [NVTransfer] = []
		
		for link in _story.getLinksFrom(linkable: node) {
			if !link.PreCondition.evaluate() {
				NVLog.log("Link (\(link.ID)) ignored as its precondition failed.", level: .info)
				continue
			}
			
			guard let dest = link.Transfer.Destination else {
				NVLog.log("Link (\(link.ID)) ignored as its transfer destination was nil.", level: .info)
				continue
			}
			
			// if a branch, both transfers must be valid
			if let asBranch = dest as? NVBranch {
				if asBranch.TrueTransfer.Destination == nil || asBranch.FalseTransfer.Destination == nil {
					NVLog.log("Link/Branch (\(link.ID)) ignored as its true or false destination was nil.", level: .info)
					continue
				}
			}
			
			// a switch must have at least a valid default transfer and all valid options
			if let asSwitch = dest as? NVSwitch {
				if asSwitch.DefaultOption.transfer.Destination == nil {
					continue
				}
				var isNil = false
				for opt in asSwitch.Options {
					if opt.transfer.Destination == nil {
						isNil = true
						break
					}
				}
				if isNil {
					continue
				}
			}
			
			// it is okay to add this link
			xfers.append(link.Transfer)
		}
		
		return xfers
	}
}
