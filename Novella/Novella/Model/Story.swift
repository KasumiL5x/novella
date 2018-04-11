//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Story {
	var _rootVariableSet: Folder
	var _flowGraphs: [FlowGraph]
	
	init() {
		self._rootVariableSet = Folder(name: "story")
		self._flowGraphs = []
	}
}
