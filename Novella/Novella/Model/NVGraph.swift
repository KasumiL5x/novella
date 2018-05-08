//
//  NVGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVGraph {
	var _uuid: NSUUID
	var _name: String
	var _graphs: [NVGraph]
	var _nodes: [NVNode]
	var _links: [NVBaseLink]
	var _listeners: [NVListener]
	var _exits: [NVExitNode]
	var _entry: NVLinkable?
	
	// parent flow graph is valid unless as a direct child of the story
	var _parent: NVGraph?
	var _story: NVStory?
	
	init(uuid: NSUUID, name: String, story: NVStory) {
		self._uuid = uuid
		self._name = name
		self._graphs = []
		self._nodes = []
		self._links = []
		self._listeners = []
		self._exits = []
		self._entry = nil
		self._parent = nil
		self._story = story
	}
	
	// MARK:  Getters
	var Name:      String      {get{ return _name }}
	var Graphs:    [NVGraph] {get{ return _graphs }}
	var Nodes:     [NVNode]  {get{ return _nodes }}
	var Links:     [NVBaseLink]  {get{ return _links }}
	var Listeners: [NVListener]  {get{ return _listeners }}
	var Exits:     [NVExitNode]  {get{ return _exits }}
	var Entry:     NVLinkable?   {get{ return _entry }}
	
	// MARK: Setters
	func setName(name: String) throws {
		assert(_story != nil, "FlowGraph::setName - _story is nil.")
		
		// if there's no parent graph, check siblings of the story for name clashes
		if nil == _parent {
			if _story!.containsGraphName(name) {
				throw NVError.nameAlreadyTaken("Tried to change FlowGraph \(_name) to \(name), but the Story already contains that name.")
			}
			_name = name
			return
		}
		
		// parent graph can't contain same name
		if _parent != nil {
			if _parent!.containsGraphName(name: name) {
				throw NVError.nameAlreadyTaken("Tried to change FlowGraph \(_name) to \(name), but the parent FlowGraph (\(_parent!._name)) already contains that name.")
			}
			_name = name
			return
		}
		
		throw NVError.invalid("Oh dear.")
	}
	
	func setEntry(entry: NVLinkable) throws {
		if let fg = entry as? NVGraph {
			if !contains(graph: fg) {
				throw NVError.invalid("Tried to set FlowGraph's entry but it wasn't a child (\(_name)).")
			}
		}
		if let fn = entry as? NVNode {
			if !contains(node: fn) {
				throw NVError.invalid("Tried to set FlowGraph's entry but it wasn't a child (\(_name)).")
			}
		}
		_entry = entry
	}
	
	// MARK: Sub-FlowGraphs
	func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	func containsGraphName(name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	@discardableResult
	func add(graph: NVGraph) throws -> NVGraph {
		// cannot add self
		if graph == self {
			throw NVError.invalid("Tried to add a FlowGraph to self (\(_name)).")
		}
		// already a child
		if contains(graph: graph) {
			throw NVError.invalid("Tried to add a FlowGraph but it already exists (\(graph._name) to \(_name)).")
		}
		// already contains same name
		if containsGraphName(name: graph._name) {
			throw NVError.nameTaken("Tried to add a FlowGraph but its name was already in use (\(graph._name) to \(_name)).")
		}
		// unparent first
		if graph._parent != nil {
			try! graph._parent!.remove(graph: graph)
		}
		// now add
		graph._parent = self
		_graphs.append(graph)
		return graph
	}
	
	func remove(graph: NVGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw NVError.invalid("Tried to remove FlowGraph (\(graph._name)) from (\(_name)) but it was not a child.")
		}
		_graphs[idx]._parent = nil
		_graphs.remove(at: idx)
	}
	
	// MARK: FlowNodes
	func contains(node: NVNode) -> Bool {
		return _nodes.contains(node)
	}
	
	@discardableResult
	func add(node: NVNode) throws -> NVNode {
		// already a child
		if contains(node: node) {
			throw NVError.invalid("Tried to add a FlowNode but it already exists (to \(_name)).")
		}
		_nodes.append(node)
		return node
	}
	
	func remove(node: NVNode) throws {
		guard let idx = _nodes.index(of: node) else {
			throw NVError.invalid("Tried to remove a FlowNode from (\(_name)) but it was not a child.")
		}
		_nodes.remove(at: idx)
	}
	
	// MARK: Links
	func contains(link: NVBaseLink) -> Bool {
		return _links.contains(link)
	}
	
	@discardableResult
	func add(link: NVBaseLink) throws -> NVBaseLink {
		// already a child
		if contains(link: link) {
			throw NVError.invalid("Tried to add a BaseLink but it already exists (to \(_name)).")
		}
		_links.append(link)
		return link
	}
	
	func remove(link: NVBaseLink) throws {
		guard let idx = _links.index(of: link) else {
			throw NVError.invalid("Tried to remove BaseLink from (\(_name)) but it was not a child.")
		}
		_links.remove(at: idx)
	}
	
	// MARK: Listeners
	func contains(listener: NVListener) -> Bool {
		return _listeners.contains(listener)
	}
	
	@discardableResult
	func add(listener: NVListener) throws -> NVListener {
		// already a child
		if contains(listener: listener) {
			throw NVError.invalid("Tried to add a Listener but it already exists (to FlowGraph \(_name)).")
		}
		_listeners.append(listener)
		return listener
	}
	
	func remove(listener: NVListener) throws {
		guard let idx = _listeners.index(of: listener) else {
			throw NVError.invalid("Tried to remove Listener from FlowGraph (\(_name)) but it was not a child.")
		}
		_listeners.remove(at: idx)
	}
	
	// MARK: Exit Nodes
	func contains(exit: NVExitNode) -> Bool {
		return _exits.contains(exit)
	}
	
	@discardableResult
	func add(exit: NVExitNode) throws -> NVExitNode {
		// already a child
		if contains(exit: exit) {
			throw NVError.invalid("Tried to add an ExitNode but it alerady exists (to FlowGraph \(_name)).")
		}
		_exits.append(exit)
		return exit
	}
	
	func remove(exit: NVExitNode) throws {
		guard let idx = _exits.index(of: exit) else {
			throw NVError.invalid("Tried to remove ExitNode from FlowGraph (\(_name)) but it was not a child.")
		}
		_exits.remove(at: idx)
	}
	
	// MARK: Simulation
	func canSimulate() -> Bool {
		return _nodes.count > 0 && _entry != nil
	}
}

// MARK: Pathable
extension NVGraph: NVPathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> NVPathable? {
		return _parent
	}
}

// MARK: Identifiable
extension NVGraph: NVIdentifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Linkable
extension NVGraph: NVLinkable {
}

// MARK: Equatable
extension NVGraph: Equatable {
	static func == (lhs: NVGraph, rhs: NVGraph) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
