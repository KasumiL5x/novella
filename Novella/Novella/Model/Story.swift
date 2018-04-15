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
	
	func add(graph: FlowGraph) throws {
		// already a child
		
		// already contains same name
		// unparent if parent exists
		// reparent to this
		// then add
	}
	
	func remove(graph: FlowGraph) throws {
		
	}
}
