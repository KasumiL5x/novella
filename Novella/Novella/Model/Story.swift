//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Story {
	var _mainFolder: Folder
	var _graphs: [FlowGraph]
	var _links: [BaseLink]
	
	// primary graph
	// TODO: Make this non-deletable
	var _mainGraph: FlowGraph? = nil
	
	init() {
		self._mainFolder = Folder(name: "story")
		self._graphs = []
		self._links = []
		
		// add first graph
		self._mainGraph = try! makeGraph(name: "main")
	}
	
	// MARK: Getters
	var MainGraph: FlowGraph {get{ return _mainGraph! }}
	var MainFolder: Folder {get{ return _mainFolder }}
	
	// MARK: Setup
	func setup() throws {
		throw Errors.notImplemented("Story::setup()")
	}
	
	// MARK: FlowGraphs
	func contains(graph: FlowGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	func containsGraphName(name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	func add(graph: FlowGraph) throws {
		// already a child
		if contains(graph: graph) {
			throw Errors.invalid("Tried to add a FlowGraph but it already exists (\(graph._name) to story).")
		}
		// already contains same name
		if containsGraphName(name: graph._name) {
			throw Errors.nameTaken("Tried to add a FlowGraph but its name was already in use (\(graph._name) to story).")
		}
		// unparent first
		if graph._parent != nil {
			try graph._parent?.remove(graph: graph)
		}
		// now add
		graph._parent = nil
		_graphs.append(graph)
	}
	
	func remove(graph: FlowGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from story but it was not a child.")
		}
		_graphs.remove(at: idx)
	}
	
	// MARK: FlowGraph Convenience Functions
	func makeGraph(name: String) throws -> FlowGraph {
		let fg = FlowGraph(name: name, story: self)
		try add(graph: fg)
		return fg
	}
	
	// MARK: Links
	func add(link: BaseLink) {
		_links.append(link)
	}
	func remove(link: BaseLink) throws {
		guard let idx = _links.index(of: link) else {
			throw Errors.invalid("Tried to remove BaseLink from Story but it was not a child.")
		}
		_links.remove(at: idx)
	}
	
	// MARK: Link Convenience Functions
	func makeLink(origin: Linkable, destination: Linkable?) {
		let link = Link()
		link.origin = origin
		link.transfer.destination = destination
		add(link: link)
	}
}
