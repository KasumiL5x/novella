//
//  SelectionHandler.swift
//  Novella
//
//  Created by Daniel Green on 23/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class SelectionHandler {
	// MARK: - Variables -
	private var _selectedNodes: [Node]
	private var _delegate: GraphViewDelegate?
	private var _graph: GraphView
	
	// MARK: - Initialization -
	init(graph: GraphView) {
		self._selectedNodes = []
		self._graph = graph
	}
	
	// MARK: - Properties -
	var Selection: [Node] {
		get{ return _selectedNodes }
	}
	var Delegate: GraphViewDelegate? {
		get{ return _delegate }
		set{ _delegate = newValue }
	}
	
	// MARK: - Functions -
	func select(_ nodes: [Node], append: Bool) {
		_selectedNodes.forEach({$0.deselect()})
		_selectedNodes = append ? (_selectedNodes + nodes) : nodes
		_selectedNodes.forEach({$0.select()})
		
		_delegate?.onSelectionChanged(graphView: _graph, selection: _selectedNodes)
	}
	
	func deselect(_ nodes: [Node]) {
		nodes.forEach({
			if _selectedNodes.contains($0) {
				$0.deselect()
				_selectedNodes.remove(at: _selectedNodes.index(of: $0)!)
			}
		})
		
		_delegate?.onSelectionChanged(graphView: _graph, selection: _selectedNodes)
	}
}
