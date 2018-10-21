//
//  NVGraph.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVGraph: NVIdentifiable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	
	// MARK: - Properties
	private(set) var Parent: NVGraph?
	var Name: String = "" {
		didSet {
			NVLog.log("Graph (\(ID)) renamed (\(oldValue)->\(Name)).", level: .info)
			_story.Delegates.forEach{$0.nvGraphDidRename(graph: self)}
		}
	}
	private(set) var Graphs: [NVGraph] = []
	private(set) var Nodes: [NVNode] = []
	private(set) var Links: [NVLink] = []
	private(set) var Branches: [NVBranch] = []
	private(set) var Switches: [NVSwitch] = []
	var Entry: NVNode? = nil {
		didSet {
			// safety checks
			if let notNil = Entry {
				if !contains(node: notNil) {
					NVLog.log("Tried to set Graph (\(ID)) entry to (\(notNil.ID)) but it was not contained. Entry will be set to nil.", level: .warning)
					Entry = nil
					return
				}
			}
			NVLog.log("Graph (\(ID)) entry set to (\(Entry?.ID.uuidString ?? "nil")).", level: .info)
			_story.Delegates.forEach{$0.nvGraphDidSetEntry(graph: self, entry: Entry)}
		}
	}
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory, name: String) {
		self.ID = id
		self._story = story
		self.Parent = nil
		self.Name = name
	}
	
	// MARK: - Graphs
	func contains(graph: NVGraph) -> Bool {
		return Graphs.contains(graph)
	}
	@discardableResult func add(graph: NVGraph) -> NVGraph {
		if graph == self {
			NVLog.log("Tried to add Graph to self (\(ID)).", level: .warning)
			return self
		}
		
		if contains(graph: graph) {
			NVLog.log("Tried to add Graph (\(graph.ID)) to Graph (\(ID)) but it was already added.", level: .warning)
			return graph
		}
		
		if let oldParent = graph.Parent {
			oldParent.remove(graph: graph)
		}
		graph.Parent = self
		Graphs.append(graph)
		
		NVLog.log("Graph (\(graph.ID)) added to Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidAddGraph(parent: self, child: graph)}
		return graph
	}
	func remove(graph: NVGraph) {
		guard let idx = Graphs.index(of: graph) else {
			NVLog.log("Tried to remove Graph (\(graph.ID)) from Graph (\(ID)) but it was not contained.", level: .warning)
			return
		}
		Graphs[idx].Parent = nil
		Graphs.remove(at: idx)
		
		NVLog.log("Removed Graph (\(graph.ID)) from Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidRemoveGraph(parent: self, child: graph)}
	}
	
	// MARK: - Nodes
	func contains(node: NVNode) -> Bool {
		return Nodes.contains(node)
	}
	@discardableResult func add(node: NVNode) -> NVNode {
		if contains(node: node) {
			NVLog.log("Tried to add Node (\(node.ID)) to Graph (\(ID)) but it was already contained.", level: .warning)
			return node
		}
		Nodes.append(node)
		
		NVLog.log("Node (\(node.ID)) added to Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidAddNode(parent: self, child: node)}
		return node
	}
	func remove(node: NVNode) {
		guard let idx = Nodes.index(of: node) else {
			NVLog.log("Tried to remove Node (\(node.ID)) from Graph (\(ID)) but it was not contained.", level: .warning)
			return
		}
		Nodes.remove(at: idx)
		
		NVLog.log("Node (\(node.ID)) removed from Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidRemoveNode(parent: self, child: node)}
	}
	
	// MARK: - Links
	func contains(link: NVLink) -> Bool {
		return Links.contains(link)
	}
	@discardableResult func add(link: NVLink) -> NVLink {
		if contains(link: link) {
			NVLog.log("Tried to add Link (\(link.ID)) to Graph (\(ID)) but it was already contained.", level: .warning)
			return link
		}
		Links.append(link)
		
		NVLog.log("Link (\(link.ID)) added to Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidAddLink(graph: self, link: link)}
		return link
	}
	func remove(link: NVLink) {
		guard let idx = Links.index(of: link) else {
			NVLog.log("Tried to remove Link (\(link.ID)) from Graph (\(ID)) but it was not contained.", level: .warning)
			return
		}
		Links.remove(at: idx)
		
		_story.Delegates.forEach{$0.nvGraphDidRemoveLink(graph: self, link: link)}
	}
	
	// MARK: - Branches
	func contains(branch: NVBranch) -> Bool {
		return Branches.contains(branch)
	}
	@discardableResult func add(branch: NVBranch) -> NVBranch {
		if contains(branch: branch) {
			NVLog.log("Tried to add Branch (\(branch.ID)) to Graph (\(ID)) but it was already contained.", level: .warning)
			return branch
		}
		Branches.append(branch)
		
		NVLog.log("Branch (\(branch.ID)) added to Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidAddBranch(graph: self, branch: branch)}
		return branch
	}
	func remove(branch: NVBranch) {
		guard let idx = Branches.index(of: branch) else {
			NVLog.log("Tried to remove Branch (\(branch.ID)) from Graph (\(ID)) but it was not contained.", level: .warning)
			return
		}
		Branches.remove(at: idx)
		
		_story.Delegates.forEach{$0.nvGraphDidRemoveBranch(graph: self, branch: branch)}
	}
	
	// MARK: - Switches
	func contains(swtch: NVSwitch) -> Bool {
		return Switches.contains(swtch)
	}
	@discardableResult func add(swtch: NVSwitch) -> NVSwitch {
		if contains(swtch: swtch) {
			NVLog.log("Tried to add Switch (\(swtch.ID)) to Graph (\(ID)) but it was already contained.", level: .warning)
			return swtch
		}
		Switches.append(swtch)
		
		NVLog.log("Switch (\(swtch.ID)) added to Graph (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvGraphDidAddSwitch(graph: self, swtch: swtch)}
		return swtch
	}
	func remove(swtch: NVSwitch) {
		guard let idx = Switches.index(of: swtch) else {
			NVLog.log("Tried to remove Switch (\(swtch.ID)) from Graph (\(ID)) but it was not contained.", level: .warning)
			return
		}
		Switches.remove(at: idx)
		
		_story.Delegates.forEach{$0.nvGraphDidRemoveSwitch(graph: self, swtch: swtch)}
	}
}

extension NVGraph: Equatable {
	static func ==(lhs: NVGraph, rhs: NVGraph) -> Bool {
		return lhs.ID == rhs.ID
	}
}
