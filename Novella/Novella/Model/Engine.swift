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
	
	init() {
		self._story = Story()
		self._identifiables = []
		
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
		_identifiables.append(folder)
		return folder
	}
	
	// MARK: Variables
	func makeVariable(name: String, type: DataType) -> Variable {
		let variable = Variable(uuid: NSUUID(), name: name, type: type)
		_identifiables.append(variable)
		return variable
	}
	
	// MARK: FlowGraphs
	func makeFlowGraph(name: String) -> FlowGraph {
		let graph = FlowGraph(name: name, story: _story)
		_identifiables.append(graph)
		return graph
	}
}
