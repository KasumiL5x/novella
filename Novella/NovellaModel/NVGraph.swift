//
//  NVGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVGraph: NVObject {
	// MARK: - Variables -
	internal var _graphs: [NVGraph]
	internal var _nodes: [NVNode]
	internal var _links: [NVBaseLink]
	internal var _listeners: [NVListener]
	internal var _exits: [NVExitNode]
	internal var _entry: NVObject?
	// parent graph is valid unless as a direct child of the story
	internal var _parent: NVGraph?
	
	// MARK: - Properties -
	public var Graphs: [NVGraph] {
		get{ return _graphs }
	}
	public var Nodes: [NVNode] {
		get{ return _nodes }
	}
	public var Links: [NVBaseLink] {
		get{ return _links }
	}
	public var Listeners: [NVListener] {
		get{ return _listeners }
	}
	public var Exits: [NVExitNode] {
		get{ return _exits }
	}
	public var Entry: NVObject? {
		get{ return _entry }
	}
	public var Parent: NVGraph? {
		get{ return _parent }
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager, uuid: NSUUID, name: String) {
		self._graphs = []
		self._nodes = []
		self._links = []
		self._listeners = []
		self._exits = []
		self._entry = nil
		self._parent = nil
		super.init(manager: manager, uuid: uuid)
		self.Name = name
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return true
	}
	
	// MARK: Setters
	public func setEntry(_ entry: NVObject) throws {
		if let fg = entry as? NVGraph {
			if !contains(graph: fg) {
				throw NVError.invalid("Tried to set Graph's entry but it wasn't a child (\(Name)).")
			}
		}
		if let fn = entry as? NVNode {
			if !contains(node: fn) {
				throw NVError.invalid("Tried to set Graph's entry but it wasn't a child (\(Name)).")
			}
		}
		_entry = entry
		
		_manager.Delegates.forEach{$0.onStoryGraphSetEntry(entry: entry, graph: self)}
	}
	
	// MARK: Subgraphs
	public func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	public func containsGraphName(_ name: String) -> Bool {
		return _graphs.contains(where: {$0.Name == name})
	}
	
	@discardableResult
	public func add(graph: NVGraph) throws -> NVGraph {
		// cannot add self
		if graph == self {
			throw NVError.invalid("Tried to add a Graph to self (\(Name)).")
		}
		// already a child
		if contains(graph: graph) {
			throw NVError.invalid("Tried to add a Graph but it already exists (\(graph.Name) to \(Name)).")
		}
		// unparent first
		if graph._parent != nil {
			try! graph._parent!.remove(graph: graph)
		}
		// now add
		graph._parent = self
		_graphs.append(graph)
		
		_manager.Delegates.forEach{$0.onStoryGraphAddGraph(graph: graph, parent: self)}
		return graph
	}
	
	public func remove(graph: NVGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw NVError.invalid("Tried to remove Graph (\(graph.Name)) from (\(Name)) but it was not a child.")
		}
		_graphs[idx]._parent = nil
		_graphs.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryGraphRemoveGraph(graph: graph, from: self)}
	}
	
	// MARK: Nodes
	public func contains(node: NVNode) -> Bool {
		return _nodes.contains(node)
	}
	
	@discardableResult
	public func add(node: NVNode) throws -> NVNode {
		// already a child
		if contains(node: node) {
			throw NVError.invalid("Tried to add a Node but it already exists (to \(Name)).")
		}
		_nodes.append(node)
		
		_manager.Delegates.forEach{$0.onStoryGraphAddNode(node: node, parent: self)}
		return node
	}
	
	public func remove(node: NVNode) throws {
		guard let idx = _nodes.index(of: node) else {
			throw NVError.invalid("Tried to remove a Node from (\(Name)) but it was not a child.")
		}
		_nodes.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryGraphRemoveNode(node: node, from: self)}
	}
	
	// MARK: Links
	public func contains(link: NVBaseLink) -> Bool {
		return _links.contains(link)
	}
	
	@discardableResult
	public func add(link: NVBaseLink) throws -> NVBaseLink {
		// already a child
		if contains(link: link) {
			throw NVError.invalid("Tried to add a BaseLink but it already exists (to \(Name)).")
		}
		_links.append(link)
		
		_manager.Delegates.forEach{$0.onStoryGraphAddLink(link: link, parent: self)}
		return link
	}
	
	public func remove(link: NVBaseLink) throws {
		guard let idx = _links.index(of: link) else {
			throw NVError.invalid("Tried to remove BaseLink from (\(Name)) but it was not a child.")
		}
		_links.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryGraphRemoveLink(link: link, from: self)}
	}
	
	// MARK: Listeners
	public func contains(listener: NVListener) -> Bool {
		return _listeners.contains(listener)
	}
	
	@discardableResult
	public func add(listener: NVListener) throws -> NVListener {
		// already a child
		if contains(listener: listener) {
			throw NVError.invalid("Tried to add a Listener but it already exists (to Graph \(Name)).")
		}
		_listeners.append(listener)
		
		_manager.Delegates.forEach{$0.onStoryGraphAddListener(listener: listener, parent: self)}
		return listener
	}
	
	public func remove(listener: NVListener) throws {
		guard let idx = _listeners.index(of: listener) else {
			throw NVError.invalid("Tried to remove Listener from Graph (\(Name)) but it was not a child.")
		}
		_listeners.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryGraphRemoveListener(listener: listener, from: self)}
	}
	
	// MARK: Exit Nodes
	public func contains(exit: NVExitNode) -> Bool {
		return _exits.contains(exit)
	}
	
	@discardableResult
	public func add(exit: NVExitNode) throws -> NVExitNode {
		// already a child
		if contains(exit: exit) {
			throw NVError.invalid("Tried to add an ExitNode but it alerady exists (to Graph \(Name)).")
		}
		_exits.append(exit)
		
		_manager.Delegates.forEach{$0.onStoryGraphAddExit(exit: exit, parent: self)}
		return exit
	}
	
	public func remove(exit: NVExitNode) throws {
		guard let idx = _exits.index(of: exit) else {
			throw NVError.invalid("Tried to remove ExitNode from Graph (\(Name)) but it was not a child.")
		}
		_exits.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryGraphRemoveExit(exit: exit, from: self)}
	}
	
	// MARK: Simulation
	public func canSimulate() -> Bool {
		return _nodes.count > 0 && _entry != nil
	}
}

// MARK: NVPathable
extension NVGraph: NVPathable {
	public func localPath() -> String {
		return Name
	}
	
	public func parentPath() -> NVPathable? {
		return _parent
	}
}
