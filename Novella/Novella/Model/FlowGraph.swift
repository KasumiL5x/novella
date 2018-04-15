//
//  FlowGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class FlowGraph {
	var _name: String
	var _graphs: [FlowGraph]
	var _nodes: [FlowNode]
	var _links: [BaseLink]
	
	// only one of these should be valid
	var _parentStory: Story?
	var _parentGraph: FlowGraph?
	
	init(name: String) {
		self._name = name
		self._graphs = []
		self._nodes = []
		self._links = []
		self._parentStory = nil
		self._parentGraph = nil
	}
	
	// MARK:  Getters
	var Name: String {get{ return _name }}
	
	// MARK: Helper Functions
	func unparent() throws {
		if _parentStory != nil {
			try _parentStory!.remove(graph: self)
			_parentStory = nil
		}
		if _parentGraph != nil {
			try _parentGraph!.remove(graph: self)
			_parentGraph = nil
		}
	}
	
	// MARK: Sub-FlowGraphs
	func contains(graph: FlowGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	func containsGraphName(name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	func add(graph: FlowGraph) throws {
		// cannot add self
		if graph == self {
			throw Errors.invalid("Tried to add a FlowGraph to self (\(_name)).")
		}
		// already a child
		if contains(graph: graph) {
			throw Errors.invalid("Tried to add a FlowGraph but it already exists (\(graph._name) to \(_name)).")
		}
		// already contains same name
		if containsGraphName(name: graph._name) {
			throw Errors.nameTaken("Tried to add a FlowGraph but its name was already in use (\(graph._name) to \(_name)).")
		}
		// unparent first
		try graph.unparent()
		// now add
		graph._parentStory = nil
		graph._parentGraph = self
		_graphs.append(graph)
	}
	
	func remove(graph: FlowGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from (\(_name)) but it was not a child.")
		}
		_graphs[idx]._parentGraph = nil
		_graphs.remove(at: idx)
	}
	
	// MARK: Sub-FlowGraph Convenience Functions
	func makeGraph(name: String) throws -> FlowGraph {
		let fg = FlowGraph(name: name)
		try add(graph: fg)
		return fg
	}
}

// MARK: Pathable
extension FlowGraph: Pathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> Pathable? {
		// cna have two parents
		return _parentStory != nil ? _parentStory : _parentGraph
	}
}

// MARK: Equatable
extension FlowGraph: Equatable {
	static func == (lhs: FlowGraph, rhs: FlowGraph) -> Bool {
		return Path.fullPathTo(object: lhs) == Path.fullPathTo(object: rhs)
	}
}
