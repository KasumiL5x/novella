//
//  FlowGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class FlowGraph {
	var _name: String
	var _nodes: [FlowNode]
	var _links: [BaseLink]
	
	init(name: String) {
		self._name = name
		self._nodes = []
		self._links = []
	}
}
