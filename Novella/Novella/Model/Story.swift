//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Story {
	var _graphs: [FlowGraph]
	var _links: [BaseLink]
	var _folders: [Folder]
	
	init() {
		self._graphs = []
		self._links = []
		self._folders = []
	}
	
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
	
	@discardableResult
	func add(graph: FlowGraph) throws -> FlowGraph {
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
		return graph
	}
	
	func remove(graph: FlowGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from story but it was not a child.")
		}
		_graphs.remove(at: idx)
	}
	
	// MARK: Links
	@discardableResult
	func add(link: BaseLink) -> BaseLink {
		_links.append(link)
		return link
	}
	func remove(link: BaseLink) throws {
		guard let idx = _links.index(of: link) else {
			throw Errors.invalid("Tried to remove BaseLink from Story but it was not a child.")
		}
		_links.remove(at: idx)
	}
	
	// MARK: Folders
	func contains(folder: Folder) -> Bool {
		return _folders.contains(folder)
	}
	func containsFolderName(name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	@discardableResult
	func add(folder: Folder) throws -> Folder {
		// already a child
		if contains(folder: folder) {
			throw Errors.invalid("Tried to add a Folder but it already exists (\(folder._name) to story).")
		}
		// already contains same name
		if containsFolderName(name: folder._name) {
			throw Errors.nameTaken("Tried to add a Folder but its name was already in use (\(folder._name) to story).")
		}
		// now add
		_folders.append(folder)
		return folder
	}
}
