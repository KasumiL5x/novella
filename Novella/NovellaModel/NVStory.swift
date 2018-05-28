//
//  NVStory.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import JavaScriptCore

public class NVStory {
	// MARK: Story
	var _folders: [NVFolder]
	var _graphs: [NVGraph]
	var _name: String
	var _delegate: NVStoryDelegate?
	
	public init() {
		self._folders = []
		self._graphs = []
		self._name = ""
		self._delegate = nil
	}
	
	// MARK: Properties
	public var Folders:  [NVFolder]   {get{ return _folders }}
	public var Graphs:   [NVGraph]    {get{ return _graphs }}
	public var Name:     String       {
		get{ return _name }
		set{ _name = newValue }
	}
}

// MARK: Story Functions
extension NVStory {
	// MARK: Folders
	public func contains(folder: NVFolder) -> Bool {
		return _folders.contains(folder)
	}
	
	public func containsFolderName(_ name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	@discardableResult
	public func add(folder: NVFolder) throws -> NVFolder {
		// already a child
		if contains(folder: folder) {
			throw NVError.invalid("Tried to add a Folder but it already exists (\(folder._name) to story).")
		}
		// now add
		_folders.append(folder)
		
		_delegate?.onStoryAddFolder(folder: folder)
		return folder
	}
	
	public func remove(folder: NVFolder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw NVError.invalid("Tried to remove Folder (\(folder._name)) from story but it was not a child.")
		}
		_folders.remove(at: idx)
		
		_delegate?.onStoryRemoveFolder(folder: folder)
	}
	
	// MARK: Graphs
	public func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	public func containsGraphName(_ name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	@discardableResult
	public func add(graph: NVGraph) throws -> NVGraph {
		// already a child
		if contains(graph: graph) {
			throw NVError.invalid("Tried to add a Graph but it already exists (\(graph._name) to story).")
		}
		// unparent first
		if graph._parent != nil {
			try graph._parent?.remove(graph: graph)
		}
		// now add
		graph._parent = nil
		_graphs.append(graph)
		
		_delegate?.onStoryAddGraph(graph: graph)
		return graph
	}
	
	public func remove(graph: NVGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw NVError.invalid("Tried to remove Graph (\(graph._name)) from story but it was not a child.")
		}
		_graphs.remove(at: idx)
		
		_delegate?.onStoryRemoveGraph(graph: graph)
	}
}
