//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Story {
	var _rootFolder: Folder
	var _graphs: [FlowGraph]
	
	init() {
		self._rootFolder = Folder(name: "story")
		self._graphs = []
	}
	
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
		try graph.unparent()
		// now add
		graph._parentStory = self
		graph._parentGraph = nil
		_graphs.append(graph)
	}
	
	func remove(graph: FlowGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from story but it was not a child.")
		}
		_graphs[idx]._parentStory = nil
		_graphs.remove(at: idx)
	}
	
	// MARK: FlowGraph Convenience Functions
	func makeGraph(name: String) throws -> FlowGraph {
		let fg = FlowGraph(name: name)
		try add(graph: fg)
		return fg
	}
}

// MARK: Pathable
extension Story: Pathable {
	func localPath() -> String {
		return "story"
	}
	
	func parentPath() -> Pathable? {
		return nil // highest level object
	}
}
