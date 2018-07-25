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
	// MARK: - Variables -
	private let _manager: NVStoryManager
	private var _folders: [NVFolder]
	private var _graphs: [NVGraph]
	private var _name: String
	
	// MARK: - Properties -
	public var Folders: [NVFolder] {
		get{ return _folders }
	}
	public var Graphs: [NVGraph] {
		get{ return _graphs }
	}
	public var Name: String {
		get{ return _name }
		set{
			_name = newValue
			_manager.Delegates.forEach{$0.onStoryNameChanged(story: self, name: _name)}
		}
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager) {
		self._manager = manager
		self._folders = []
		self._graphs = []
		self._name = ""
	}
	
	// MARK: - Functions -
	// MARK: Folders
	public func contains(folder: NVFolder) -> Bool {
		return _folders.contains(folder)
	}
	
	public func containsFolderName(_ name: String) -> Bool {
		return _folders.contains(where: {$0.Name == name})
	}
	
	@discardableResult
	public func add(folder: NVFolder) -> NVFolder {
		// already a child
		if contains(folder: folder) {
			NVLog.log("Tried to add Folder (\(folder.UUID.uuidString)) to Story but it was already a child.", level: .warning)
			return folder
		}
		// now add
		_folders.append(folder)
		
		_manager.Delegates.forEach{$0.onStoryAddFolder(folder: folder)}
		return folder
	}
	
	public func remove(folder: NVFolder) {
		guard let idx = _folders.index(of: folder) else {
			NVLog.log("Tried to remove Folder (\(folder.UUID.uuidString)) from Story but it was not a child.", level: .warning)
			return
		}
		_folders.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryRemoveFolder(folder: folder)}
	}
	
	// MARK: Graphs
	public func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	public func containsGraphName(_ name: String) -> Bool {
		return _graphs.contains(where: {$0.Name == name})
	}
	
	@discardableResult
	public func add(graph: NVGraph) -> NVGraph {
		// already a child
		if contains(graph: graph) {
			NVLog.log("Tried to add Graph (\(graph.UUID.uuidString)) to Story but it was already a child.", level: .warning)
			return graph
		}
		// unparent first
		if graph._parent != nil {
			graph._parent?.remove(graph: graph)
		}
		// now add
		graph._parent = nil
		_graphs.append(graph)
		
		_manager.Delegates.forEach{$0.onStoryAddGraph(graph: graph)}
		return graph
	}
	
	public func remove(graph: NVGraph) {
		guard let idx = _graphs.index(of: graph) else {
			NVLog.log("Tried to remove Graph (\(graph.UUID.uuidString)) from Story but it was already a child.", level: .warning)
			return
		}
		_graphs.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryRemoveGraph(graph: graph)}
	}
}
