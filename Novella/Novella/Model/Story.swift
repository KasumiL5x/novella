//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Story {
	// MARK: Storywide Collections
	var _allIdentifiables: [Identifiable]
	var _allFolders: [Folder]
	var _allVariables: [Variable]
	var _allGraphs: [FlowGraph]
	var _allLinks: [Link]
	
	// MARK: Local Collections
	var _folders: [Folder]
	var _graphs: [FlowGraph]
	
	init() {
		self._allIdentifiables = []
		self._allFolders = []
		self._allVariables = []
		self._allGraphs = []
		self._allLinks = []
		
		self._folders = []
		self._graphs = []
	}
	
	// MARK: Setup
	func setup() throws {
		throw Errors.notImplemented("Story::setup()")
	}
}

// MARK: Local Collection Functions
extension Story {
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
	
	func remove(folder: Folder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw Errors.invalid("Tried to remove Folder (\(folder._name)) from story but it was not a child.")
		}
		_folders.remove(at: idx)
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
}

// MARK: Storywide Functions
extension Story {
	func findBy(uuid: String) -> Identifiable? {
		return _allIdentifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	@discardableResult
	func makeFolder(name: String, uuid: NSUUID?=nil) -> Folder {
		let folder = Folder(uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_allFolders.append(folder)
		_allIdentifiables.append(folder)
		return folder
	}
	
	@discardableResult
	func makeVariable(name: String, type: DataType, uuid: NSUUID?=nil) -> Variable {
		let variable = Variable(uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
		_allVariables.append(variable)
		_allIdentifiables.append(variable)
		return variable
	}
	
	@discardableResult
	func makeGraph(name: String, uuid: NSUUID?=nil) -> FlowGraph {
		let graph = FlowGraph(uuid: uuid != nil ? uuid! : NSUUID(), name: name, story: self)
		_allGraphs.append(graph)
		_allIdentifiables.append(graph)
		return graph
	}
	
	@discardableResult
	func makeLink(uuid: NSUUID?=nil) -> Link {
		let link = Link(uuid: uuid != nil ? uuid! : NSUUID())
		_allLinks.append(link)
		_allIdentifiables.append(link)
		return link
	}
}
