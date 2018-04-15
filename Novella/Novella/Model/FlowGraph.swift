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
	
	// parent flow graph is valid unless as a direct child of the story
	var _parent: FlowGraph?
	var _story: Story?
	
	init(name: String, story: Story) {
		self._name = name
		self._graphs = []
		self._nodes = []
		self._links = []
		self._parent = nil
		self._story = story
	}
	
	// MARK:  Getters
	var Name: String {get{ return _name }}
	
	// MARK: Setters
	func setName(name: String) throws {
		assert(_story != nil, "FlowGraph::setName - _story is nil.")
		
		// if there's no parent graph, check siblings of the story for name clashes
		if nil == _parent {
			if _story!.containsGraphName(name: name) {
				throw Errors.nameAlreadyTaken("Tried to change FlowGraph \(_name) to \(name), but the Story already contains that name.")
			}
			_name = name
			return
		}
		
		// parent graph can't contain same name
		if _parent != nil {
			if _parent!.containsGraphName(name: name) {
				throw Errors.nameAlreadyTaken("Tried to change FlowGraph \(_name) to \(name), but the parent FlowGraph (\(_parent!._name)) already contains that name.")
			}
			_name = name
			return
		}
		
		throw Errors.invalid("Oh dear.")
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
		if graph._parent != nil {
			try! graph._parent!.remove(graph: graph)
		}
		// now add
		graph._parent = self
		_graphs.append(graph)
	}
	
	func remove(graph: FlowGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from (\(_name)) but it was not a child.")
		}
		_graphs[idx]._parent = nil
		_graphs.remove(at: idx)
	}
	
	// MARK: Sub-FlowGraph Convenience Functions
	func makeGraph(name: String) throws -> FlowGraph {
		assert(_story != nil, "FlowGraph::setName - _story is nil.")
		
		let fg = FlowGraph(name: name, story: _story!)
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
		return _parent
	}
}

// MARK: Equatable
extension FlowGraph: Equatable {
	static func == (lhs: FlowGraph, rhs: FlowGraph) -> Bool {
		return Path.fullPathTo(object: lhs) == Path.fullPathTo(object: rhs)
	}
}
