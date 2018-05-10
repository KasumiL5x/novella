//
//  NVGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVGraph {
	var _uuid: NSUUID
	var _name: String
	var _graphs: [NVGraph]
	var _nodes: [NVNode]
	var _links: [NVBaseLink]
	var _listeners: [NVListener]
	var _exits: [NVExitNode]
	var _entry: NVLinkable?
	
	// parent graph is valid unless as a direct child of the story
	var _parent: NVGraph?
	var _story: NVStory
	
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
	
	// MARK:  Properties
	public var Name:      String       {get{ return _name }}
	public var Graphs:    [NVGraph]    {get{ return _graphs }}
	public var Nodes:     [NVNode]     {get{ return _nodes }}
	public var Links:     [NVBaseLink] {get{ return _links }}
	public var Listeners: [NVListener] {get{ return _listeners }}
	public var Exits:     [NVExitNode] {get{ return _exits }}
	public var Entry:     NVLinkable?  {get{ return _entry }}
	public var Parent:    NVGraph?     {get{ return _parent }}
	public var Story:     NVStory      {get{ return _story }}
	
	// MARK: Setters
	public func setName(_ name: String) throws {
		// if there's no parent graph, check siblings of the story for name clashes
		if nil == _parent {
			if _story.containsGraphName(name) {
				throw NVError.nameAlreadyTaken("Tried to change Graph \(_name) to \(name), but the Story already contains that name.")
			}
			_name = name
			return
		}
		
		// parent graph can't contain same name
		if _parent != nil {
			if _parent!.containsGraphName(name) {
				throw NVError.nameAlreadyTaken("Tried to change Graph \(_name) to \(name), but the parent Graph (\(_parent!._name)) already contains that name.")
			}
			_name = name
			return
		}
		
		throw NVError.invalid("Oh dear.")
	}
	
	public func setEntry(_ entry: NVLinkable) throws {
		if let fg = entry as? NVGraph {
			if !contains(graph: fg) {
				throw NVError.invalid("Tried to set Graph's entry but it wasn't a child (\(_name)).")
			}
		}
		if let fn = entry as? NVNode {
			if !contains(node: fn) {
				throw NVError.invalid("Tried to set Graph's entry but it wasn't a child (\(_name)).")
			}
		}
		_entry = entry
	}
	
	// MARK: Subgraphs
	public func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	public func containsGraphName(_ name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	@discardableResult
	public func add(graph: NVGraph) throws -> NVGraph {
		// cannot add self
		if graph == self {
			throw NVError.invalid("Tried to add a Graph to self (\(_name)).")
		}
		// already a child
		if contains(graph: graph) {
			throw NVError.invalid("Tried to add a Graph but it already exists (\(graph._name) to \(_name)).")
		}
		// already contains same name
		if containsGraphName(graph._name) {
			throw NVError.nameTaken("Tried to add a Graph but its name was already in use (\(graph._name) to \(_name)).")
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
	
	public func remove(graph: NVGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw NVError.invalid("Tried to remove Graph (\(graph._name)) from (\(_name)) but it was not a child.")
		}
		_graphs[idx]._parent = nil
		_graphs.remove(at: idx)
	}
	
	// MARK: Nodes
	public func contains(node: NVNode) -> Bool {
		return _nodes.contains(node)
	}
	
	@discardableResult
	public func add(node: NVNode) throws -> NVNode {
		// already a child
		if contains(node: node) {
			throw NVError.invalid("Tried to add a Node but it already exists (to \(_name)).")
		}
		_nodes.append(node)
		return node
	}
	
	public func remove(node: NVNode) throws {
		guard let idx = _nodes.index(of: node) else {
			throw NVError.invalid("Tried to remove a Node from (\(_name)) but it was not a child.")
		}
		_nodes.remove(at: idx)
	}
	
	// MARK: Links
	public func contains(link: NVBaseLink) -> Bool {
		return _links.contains(link)
	}
	
	@discardableResult
	public func add(link: NVBaseLink) throws -> NVBaseLink {
		// already a child
		if contains(link: link) {
			throw NVError.invalid("Tried to add a BaseLink but it already exists (to \(_name)).")
		}
		_links.append(link)
		return link
	}
	
	public func remove(link: NVBaseLink) throws {
		guard let idx = _links.index(of: link) else {
			throw NVError.invalid("Tried to remove BaseLink from (\(_name)) but it was not a child.")
		}
		_links.remove(at: idx)
	}
	
	// MARK: Listeners
	public func contains(listener: NVListener) -> Bool {
		return _listeners.contains(listener)
	}
	
	@discardableResult
	public func add(listener: NVListener) throws -> NVListener {
		// already a child
		if contains(listener: listener) {
			throw NVError.invalid("Tried to add a Listener but it already exists (to Graph \(_name)).")
		}
		_listeners.append(listener)
		return listener
	}
	
	public func remove(listener: NVListener) throws {
		guard let idx = _listeners.index(of: listener) else {
			throw NVError.invalid("Tried to remove Listener from Graph (\(_name)) but it was not a child.")
		}
		_listeners.remove(at: idx)
	}
	
	// MARK: Exit Nodes
	public func contains(exit: NVExitNode) -> Bool {
		return _exits.contains(exit)
	}
	
	@discardableResult
	public func add(exit: NVExitNode) throws -> NVExitNode {
		// already a child
		if contains(exit: exit) {
			throw NVError.invalid("Tried to add an ExitNode but it alerady exists (to Graph \(_name)).")
		}
		_exits.append(exit)
		return exit
	}
	
	public func remove(exit: NVExitNode) throws {
		guard let idx = _exits.index(of: exit) else {
			throw NVError.invalid("Tried to remove ExitNode from Graph (\(_name)) but it was not a child.")
		}
		_exits.remove(at: idx)
	}
	
	// MARK: Simulation
	public func canSimulate() -> Bool {
		return _nodes.count > 0 && _entry != nil
	}
}

// MARK: NVPathable
extension NVGraph: NVPathable {
	public func localPath() -> String {
		return _name
	}
	
	public func parentPath() -> NVPathable? {
		return _parent
	}
}

// MARK: NVIdentifiable
extension NVGraph: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: NVLinkable
extension NVGraph: NVLinkable {
}

// MARK: Equatable
extension NVGraph: Equatable {
	public static func == (lhs: NVGraph, rhs: NVGraph) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
