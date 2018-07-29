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
	public func setEntry(_ entry: NVObject) {
		if let fg = entry as? NVGraph {
			if !contains(graph: fg) {
				NVLog.log("Tried to set a Graph's (\(self.UUID.uuidString)) entry but it wasn't a child (\(entry.UUID.uuidString)).", level: .warning)
				return
			}
		}
		if let fn = entry as? NVNode {
			if !contains(node: fn) {
				NVLog.log("Tried to set a Graph's (\(self.UUID.uuidString)) entry but it wasn't a child (\(entry.UUID.uuidString)).", level: .warning)
				return
			}
		}
		_entry = entry
		
		NVLog.log("Graph (\(self.UUID)) Entry set to (\(entry.UUID)).", level: .info)
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
	public func add(graph: NVGraph) -> NVGraph {
		// cannot add self
		if graph == self {
			NVLog.log("Tried to add Graph to itself (\(self.UUID.uuidString)).", level: .warning)
			return self
		}
		// already a child
		if contains(graph: graph) {
			NVLog.log("Tried to add Graph (\(graph.UUID.uuidString)) to Graph (\(self.UUID.uuidString)) but it was already a child.", level: .warning)
			return graph
		}
		// unparent first
		if graph._parent != nil {
			graph._parent!.remove(graph: graph)
		}
		// now add
		graph._parent = self
		_graphs.append(graph)
		
		NVLog.log("Graph (\(graph.UUID)) added to Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphAddGraph(graph: graph, parent: self)}
		return graph
	}
	
	public func remove(graph: NVGraph) {
		guard let idx = _graphs.index(of: graph) else {
			NVLog.log("Tried to remove Graph (\(graph.UUID.uuidString)) from Graph (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_graphs[idx]._parent = nil
		_graphs.remove(at: idx)
		
		NVLog.log("Graph (\(graph.UUID)) removed from Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphRemoveGraph(graph: graph, from: self)}
	}
	
	// MARK: Nodes
	public func contains(node: NVNode) -> Bool {
		return _nodes.contains(node)
	}
	
	@discardableResult
	public func add(node: NVNode) -> NVNode {
		// already a child
		if contains(node: node) {
			NVLog.log("Tried to add Node (\(node.UUID.uuidString)) to Graph (\(self.UUID.uuidString)) but it was already a child.", level: .warning)
			return node
		}
		_nodes.append(node)
		
		NVLog.log("Node (\(node.UUID)) added to Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphAddNode(node: node, parent: self)}
		return node
	}
	
	public func remove(node: NVNode) {
		guard let idx = _nodes.index(of: node) else {
			NVLog.log("Tried to remove Node (\(node.UUID.uuidString)) from Graph (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_nodes.remove(at: idx)
		
		NVLog.log("Node (\(node.UUID)) removed from Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphRemoveNode(node: node, from: self)}
	}
	
	// MARK: Links
	public func contains(link: NVBaseLink) -> Bool {
		return _links.contains(link)
	}
	
	@discardableResult
	public func add(link: NVBaseLink) -> NVBaseLink {
		// already a child
		if contains(link: link) {
			NVLog.log("Tried to add a BaseLink (\(link.UUID.uuidString)) to Graph (\(self.UUID.uuidString)) but it was already a child.", level: .warning)
			return link
		}
		_links.append(link)
		
		NVLog.log("Link (\(link.UUID)) added to Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphAddLink(link: link, parent: self)}
		return link
	}
	
	public func remove(link: NVBaseLink) {
		guard let idx = _links.index(of: link) else {
			NVLog.log("Tried to remove BaseLink (\(link.UUID.uuidString)) from Graph (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_links.remove(at: idx)
		
		NVLog.log("Link (\(link.UUID)) removed from Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphRemoveLink(link: link, from: self)}
	}
	
	// MARK: Listeners
	public func contains(listener: NVListener) -> Bool {
		return _listeners.contains(listener)
	}
	
	@discardableResult
	public func add(listener: NVListener) -> NVListener {
		// already a child
		if contains(listener: listener) {
			NVLog.log("Tried to add Listener (\(listener.UUID.uuidString)) to Graph (\(self.UUID.uuidString)) but it was already a child.", level: .warning)
			return listener
		}
		_listeners.append(listener)
		
		NVLog.log("Listener (\(listener.UUID)) added to Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphAddListener(listener: listener, parent: self)}
		return listener
	}
	
	public func remove(listener: NVListener) {
		guard let idx = _listeners.index(of: listener) else {
			NVLog.log("Tried to remove Listener (\(listener.UUID.uuidString)) from Graph (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_listeners.remove(at: idx)
		
		NVLog.log("Listener (\(listener.UUID)) removed from Graph (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryGraphRemoveListener(listener: listener, from: self)}
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
