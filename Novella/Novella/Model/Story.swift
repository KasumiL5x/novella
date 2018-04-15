//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Story {
	var _rootFolder: Folder
	var _mainGraph: FlowGraph
	var _graphs: [FlowGraph]
	
	init() {
		self._rootFolder = Folder(name: "story")
		self._mainGraph = FlowGraph(name: "main")
		self._graphs = [self._mainGraph]
	}
	
	func setup() throws {
		throw Errors.notImplemented("Story::setup()")
	}
}
