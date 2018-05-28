//
//  NVStoryManager.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

public class NVStoryManager {
	// MARK: - - Variables -
	var _story: NVStory
	var _identifiables: [NVIdentifiable]
	var _folders: [NVFolder]
	var _variables: [NVVariable]
	var _graphs: [NVGraph]
	var _links: [NVBaseLink]
	var _nodes: [NVNode]
	var _delegate: NVStoryDelegate?
	var _jsContext: JSContext
	
	// MARK: - - Properties -
	public var Story: NVStory {
		get{ return _story }
	}
	public var Delegate: NVStoryDelegate? {
		get{ return _delegate }
		set {
			_delegate = newValue
			_story._delegate = _delegate
			_graphs.forEach{$0._delegate = _delegate}
			_nodes.forEach{$0._delegate = _delegate}
		}
	}
	
	// MARK: - - Initialization -
	public init() {
		self._story = NVStory()
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._delegate = nil
		self._jsContext = JSContext()
		
		setupJavascript()
	}
	
	// MARK: - - Generic Functions -
	public func reset() {
		self._story = NVStory()
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._delegate = nil
		self._jsContext = JSContext()
		
		setupJavascript()
	}
	
	func find(uuid: String) -> NVIdentifiable? {
		return _identifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	public func nameOf(linkable: NVLinkable?) -> String {
		switch linkable {
		case is NVNode:
			return (linkable as!  NVNode).Name
		case is NVGraph:
			return (linkable as! NVGraph).Name
		default:
			return ""
		}
	}
	
	public func getLinksFrom(_ linkable: NVLinkable) -> [NVBaseLink] {
		return _links.filter({$0._origin.UUID == linkable.UUID})
	}
	
	public func getLinksTo(_ linkable: NVLinkable) -> [NVBaseLink] {
		return _links.filter({
			
			switch $0 {
			case is NVLink:
				if let dest = ($0 as! NVLink).Transfer.Destination {
					return dest.UUID == linkable.UUID
				}
			case is NVBranch:
				if let trueDest = ($0 as! NVBranch).TrueTransfer.Destination {
					return trueDest.UUID == linkable.UUID
				}
				if let falseDest = ($0 as! NVBranch).FalseTransfer.Destination {
					return falseDest.UUID == linkable.UUID
				}
			case is NVSwitch:
				print("getLinksTo(linkable) encounterd a NVSwitch which isn't yet implemented.")
			default:
				return false
			}
			
			return false
		})
	}
	
	// MARK: - - JavaScript Stuff -
	func setupJavascript() {
		// javascript runtime error handling
		_jsContext.exceptionHandler = { (ctx, ex) in
			if let ex = ex {
				print("JavaScript error: \(ex.toString())")
			}
		}
		
		// function to print to the console from JS
		let nvLogObject = unsafeBitCast(self.js_nvlog, to: AnyObject.self)
		_jsContext.setObject(nvLogObject, forKeyedSubscript: "nvlog" as (NSCopying & NSObjectProtocol))
	}
	
	let js_nvlog: @convention(block) (String) -> Void = { msg in
		print("\nJavaScript Console: \(msg)")
	}
}

// MARK: - - Folders -
extension NVStoryManager {
	@discardableResult
	public func makeFolder(name: String, uuid: NSUUID?=nil) -> NVFolder {
		let folder = NVFolder(uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_folders.append(folder)
		_identifiables.append(folder)
		
		_delegate?.onStoryMakeFolder(folder: folder)
		return folder
	}
	
	public func delete(folder: NVFolder, deleteContents: Bool) {
		// delete children
		if deleteContents {
			for childVariable in folder._variables {
				delete(variable: childVariable)
			}
			for childFolder in folder.Folders {
				delete(folder: childFolder, deleteContents: true)
			}
		}
		
		// remove from parent
		if let parent = folder._parent {
			try! parent.remove(folder: folder)
		}
		
		// remove from story
		if self._folders.contains(folder) {
			self._folders.remove(at: self._folders.index(where: {$0 == folder})!)
		}
		
		// actual remove
		_folders.remove(at: _folders.index(where: {$0 == folder})!)
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == folder.UUID})!)
		
		_delegate?.onStoryDeleteFolder(folder: folder, contents: deleteContents)
	}
}

// MARK: - - Variables -
extension NVStoryManager {
	@discardableResult
	public func makeVariable(name: String, type: NVDataType, uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
		_variables.append(variable)
		_identifiables.append(variable)
		
		_delegate?.onStoryMakeVariable(variable: variable)
		return variable
	}
	
	public func delete(variable: NVVariable) {
		try! _folders.first(where: {$0._variables.contains(variable)})?.remove(variable: variable)
		_variables.remove(at: _variables.index(where: {$0 == variable})!)
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == variable.UUID})!)
		
		_delegate?.onStoryDeleteVariable(variable: variable)
	}
}

// MARK: - - Graphs -
extension NVStoryManager {
	@discardableResult
	public func makeGraph(name: String, uuid: NSUUID?=nil) -> NVGraph {
		let graph = NVGraph(uuid: uuid != nil ? uuid! : NSUUID(), name: name, story: _story)
		graph._delegate = _delegate
		_graphs.append(graph)
		_identifiables.append(graph)
		
		_delegate?.onStoryMakeGraph(graph: graph)
		return graph
	}
}

// MARK: - - Links -
extension NVStoryManager {
	@discardableResult
	public func makeLink(origin: NVLinkable, uuid: NSUUID?=nil) -> NVLink {
		let link = NVLink(uuid: uuid != nil ? uuid! : NSUUID(), storyManager: self, origin: origin)
		_links.append(link)
		_identifiables.append(link)
		
		_delegate?.onStoryMakeLink(link: link)
		return link
	}
	
	@discardableResult
	public func makeBranch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVBranch {
		let branch = NVBranch(uuid: uuid != nil ? uuid! : NSUUID(), storyManager: self, origin: origin)
		_links.append(branch)
		_identifiables.append(branch)
		
		_delegate?.onStoryMakeBranch(branch: branch)
		return branch
	}
	
	@discardableResult
	public func makeSwitch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVSwitch {
		let swtch = NVSwitch(uuid: uuid != nil ? uuid! : NSUUID(), storyManager: self, origin: origin)
		_links.append(swtch)
		_identifiables.append(swtch)
		
		_delegate?.onStoryMakeSwitch(switch: swtch)
		return swtch
	}
	
	public func delete(link: NVBaseLink) {
		// remove link from all graphs containing it
		_graphs.forEach { (graph) in
			if graph._links.contains(link) {
				try! graph.remove(link: link)
			}
		}
		
		_links.remove(at: _links.index(of: link)!)
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == link.UUID})!)
	}
}

// MARK: - - Nodes -
extension NVStoryManager {
	@discardableResult
	public func makeDialog(uuid: NSUUID?=nil) -> NVDialog {
		let dialog = NVDialog(uuid: uuid != nil ? uuid! : NSUUID())
		dialog._delegate = _delegate
		_nodes.append(dialog)
		_identifiables.append(dialog)
		
		_delegate?.onStoryMakeDialog(dialog: dialog)
		return dialog
	}
	
	@discardableResult
	public func makeDelivery(uuid: NSUUID?=nil) -> NVDelivery {
		let delivery = NVDelivery(uuid: uuid != nil ? uuid! : NSUUID())
		delivery._delegate = _delegate
		_nodes.append(delivery)
		_identifiables.append(delivery)
		
		_delegate?.onStoryMakeDelivery(delivery: delivery)
		return delivery
	}
	
	@discardableResult
	public func makeContext(uuid: NSUUID?=nil) -> NVContext {
		let context = NVContext(uuid: uuid != nil ? uuid! : NSUUID())
		context._delegate = _delegate
		_nodes.append(context)
		_identifiables.append(context)
		
		_delegate?.onStoryMakeContext(context: context)
		return context
	}
	
	public func delete(node: NVNode) {
		// remove from all graphs
		_graphs.forEach { (graph) in
			if graph.contains(node: node) {
				try! graph.remove(node: node)
			}
		}
		
		// any links that end in this node must have their destinations changed
		getLinksTo(node).forEach { (link) in
			switch link {
			case is NVLink:
				(link as! NVLink)._transfer._destination = nil
			case is NVBranch:
				let asBranch = link as! NVBranch
				asBranch._trueTransfer._destination = (asBranch._trueTransfer._destination?.UUID == node.UUID) ? nil : asBranch._trueTransfer._destination
				asBranch._falseTransfer._destination = (asBranch._falseTransfer._destination?.UUID == node.UUID) ? nil : asBranch._falseTransfer._destination
			case is NVSwitch:
				print("NVStoryManager::delete(node): Tried to remove node from NVSwitch but is not implemented.")
			default:
				break
			}
		}
		
		_nodes.remove(at: _nodes.index(of: node)!)
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == node.UUID})!)
	}
}



