//
//  FlowGraph.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class FlowGraph {
	var _name: String
	var _graphs: [FlowGraph]
	var _nodes: [FlowNode]
	var _links: [BaseLink]
	
	// only one of these should be valid
	var _parentStory: Story?
	var _parentGraph: FlowGraph?
	
	init(name: String) {
		self._name = name
		self._graphs = []
		self._nodes = []
		self._links = []
		self._parentStory = nil
		self._parentGraph = nil
	}
	
	// MARK:  Getters
	var Name: String {get{ return _name }}
}

// MARK: Pathable
extension FlowGraph: Pathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> Pathable? {
		// cna have two parents
		return _parentStory != nil ? _parentStory : _parentGraph
	}
}

// MARK: Equatable
extension FlowGraph: Equatable {
	static func == (lhs: FlowGraph, rhs: FlowGraph) -> Bool {
		return Path.fullPathTo(object: lhs) == Path.fullPathTo(object: rhs)
	}
}
