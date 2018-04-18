//
//  Engine.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Engine {
	let _story: Story
	
	// All objects that are Identifiable. Can be searched.
	var _identifiables: [Identifiable]
	// All Folders.
	var _folders: [Folder]
	// All Variables.
	var _variables: [Variable]
	
	init() {
		self._story = Story()
		self._identifiables = []
		self._folders = []
		self._variables = []
		
		self._story._mainFolder = makeFolder(name: "story")
		self._story._mainGraph = try! self._story.add(graph: makeFlowGraph(name: "main"))
	}
	
	// MARK: Getters
	var TheStory: Story {get{ return _story }}
	
	// MARK: Identifiables
	func find(uuid: String) throws -> Identifiable {
		let uuidObj = NSUUID(uuidString: uuid)
		guard let element = _identifiables.first(where: {$0.UUID == uuidObj}) else {
			throw Errors.invalid("Tried to find by UUID but no match was found (\(uuid)).")
		}
		return element
	}
	
	// MARK: Folders
	func makeFolder(name: String) -> Folder {
		let folder = Folder(uuid: NSUUID(), name: name)
		_folders.append(folder)
		_identifiables.append(folder)
		return folder
	}
	func addFolder(folder: Folder) {
		_folders.append(folder)
		_identifiables.append(folder)
	}
	
	// MARK: Variables
	func makeVariable(name: String, type: DataType) -> Variable {
		let variable = Variable(uuid: NSUUID(), name: name, type: type)
		_variables.append(variable)
		_identifiables.append(variable)
		return variable
	}
	func addVariable(variable: Variable) {
		_variables.append(variable)
		_identifiables.append(variable)
	}
	
	// MARK: FlowGraphs
	func makeFlowGraph(name: String) -> FlowGraph {
		let graph = FlowGraph(uuid: NSUUID(), name: name, story: _story)
		_identifiables.append(graph)
		return graph
	}
	
	// MARK: Links
	func makeLink() -> Link {
		let link = Link(uuid: NSUUID())
		_identifiables.append(link)
		return link
	}
	
	// MARK: Listener
	func makeListener() -> Listener {
		let listener = Listener(uuid: NSUUID())
		_identifiables.append(listener)
		return listener
	}
	
	// MARK: Exit Nodes
	func makeExit() -> ExitNode {
		let exit = ExitNode(uuid: NSUUID())
		_identifiables.append(exit)
		return exit
	}
}
