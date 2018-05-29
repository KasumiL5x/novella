//
//  NVStoryManager.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

public class NVStoryManager {
	// MARK: - Singleton Instance -
	public static let shared = NVStoryManager()
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory!
	fileprivate var _identifiables: [NVIdentifiable]
	fileprivate var _folders: [NVFolder]
	fileprivate var _variables: [NVVariable]
	fileprivate var _graphs: [NVGraph]
	fileprivate var _links: [NVBaseLink]
	fileprivate var _nodes: [NVNode]
	fileprivate var _trashed: [NVLinkable]
	fileprivate var _delegates: [NVStoryDelegate]
	internal var _jsContext: JSContext
	
	// MARK: - - Properties -
	public var Story: NVStory {
		get{ return _story }
	}
	public var Delegates: [NVStoryDelegate] {
		get{ return _delegates }
	}
	public var Folders: [NVFolder] {
		get{ return _folders }
	}
	public var Variables: [NVVariable] {
		get{ return _variables }
	}
	public var Graphs: [NVGraph] {
		get{ return _graphs }
	}
	public var Links: [NVBaseLink] {
		get{ return _links}
	}
	public var Nodes: [NVNode] {
		get{ return _nodes }
	}
	
	// MARK: - - Initialization -
	private init() {
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._trashed = []
		self._delegates = []
		self._jsContext = JSContext()
		self._story = NVStory()
		
		setupJavascript()
	}
	
	// MARK: - - Generic Functions -
	public func addDelegate(_ delegate: NVStoryDelegate) {
		_delegates.append(delegate)
	}
	
	public func reset() {
		self._story = NVStory()
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._trashed = []
		self._delegates = []
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
		return _links.filter({$0.Origin.UUID == linkable.UUID})
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
		
		_delegates.forEach{$0.onStoryMakeFolder(folder: folder)}
		return folder
	}
	
	public func delete(folder: NVFolder, deleteContents: Bool) {
		// delete children
		if deleteContents {
			for childVariable in folder.Variables {
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

		_delegates.forEach{$0.onStoryDeleteFolder(folder: folder, contents: deleteContents)}
	}
}

// MARK: - - Variables -
extension NVStoryManager {
	@discardableResult
	public func makeVariable(name: String, type: NVDataType, uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
		_variables.append(variable)
		_identifiables.append(variable)
		
		_delegates.forEach{$0.onStoryMakeVariable(variable: variable)}
		return variable
	}
	
	public func delete(variable: NVVariable) {
		try! _folders.first(where: {$0.Variables.contains(variable)})?.remove(variable: variable)
		_variables.remove(at: _variables.index(where: {$0 == variable})!)
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == variable.UUID})!)
		
		_delegates.forEach{$0.onStoryDeleteVariable(variable: variable)}
	}
}

// MARK: - - Graphs -
extension NVStoryManager {
	@discardableResult
	public func makeGraph(name: String, uuid: NSUUID?=nil) -> NVGraph {
		let graph = NVGraph(uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_graphs.append(graph)
		_identifiables.append(graph)
		
		_delegates.forEach{$0.onStoryMakeGraph(graph: graph)}
		return graph
	}
}

// MARK: - - Links -
extension NVStoryManager {
	@discardableResult
	public func makeLink(origin: NVLinkable, uuid: NSUUID?=nil) -> NVLink {
		let link = NVLink(uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(link)
		_identifiables.append(link)
		
		_delegates.forEach{$0.onStoryMakeLink(link: link)}
		return link
	}
	
	@discardableResult
	public func makeBranch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVBranch {
		let branch = NVBranch(uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(branch)
		_identifiables.append(branch)
		
		_delegates.forEach{$0.onStoryMakeBranch(branch: branch)}
		return branch
	}
	
	@discardableResult
	public func makeSwitch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVSwitch {
		let swtch = NVSwitch(uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(swtch)
		_identifiables.append(swtch)
		
		_delegates.forEach{$0.onStoryMakeSwitch(switch: swtch)}
		return swtch
	}
	
//	public func delete(link: NVBaseLink) {
//		// remove link from all graphs containing it
//		_graphs.forEach { (graph) in
//			if graph._links.contains(link) {
//				try! graph.remove(link: link)
//			}
//		}
//
//		_links.remove(at: _links.index(of: link)!)
//		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == link.UUID})!)
//	}
}

// MARK: - - Nodes -
extension NVStoryManager {
	@discardableResult
	public func makeDialog(uuid: NSUUID?=nil) -> NVDialog {
		let dialog = NVDialog(uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(dialog)
		_identifiables.append(dialog)
		
		_delegates.forEach{$0.onStoryMakeDialog(dialog: dialog)}
		return dialog
	}
	
	@discardableResult
	public func makeDelivery(uuid: NSUUID?=nil) -> NVDelivery {
		let delivery = NVDelivery(uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(delivery)
		_identifiables.append(delivery)
		
		_delegates.forEach{$0.onStoryMakeDelivery(delivery: delivery)}
		return delivery
	}
	
	@discardableResult
	public func makeContext(uuid: NSUUID?=nil) -> NVContext {
		let context = NVContext(uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(context)
		_identifiables.append(context)
		
		_delegates.forEach{$0.onStoryMakeContext(context: context)}
		return context
	}
	
//	public func delete(node: NVNode) {
//		// remove from all graphs
//		_graphs.forEach { (graph) in
//			if graph.contains(node: node) {
//				try! graph.remove(node: node)
//			}
//		}
//
//		// any links that end in this node must have their destinations changed
//		getLinksTo(node).forEach { (link) in
//			switch link {
//			case is NVLink:
//				(link as! NVLink)._transfer._destination = nil
//			case is NVBranch:
//				let asBranch = link as! NVBranch
//				asBranch._trueTransfer._destination = (asBranch._trueTransfer._destination?.UUID == node.UUID) ? nil : asBranch._trueTransfer._destination
//				asBranch._falseTransfer._destination = (asBranch._falseTransfer._destination?.UUID == node.UUID) ? nil : asBranch._falseTransfer._destination
//			case is NVSwitch:
//				print("NVStoryManager::delete(node): Tried to remove node from NVSwitch but is not implemented.")
//			default:
//				break
//			}
//		}
//
//		_nodes.remove(at: _nodes.index(of: node)!)
//		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == node.UUID})!)
//	}
}

// MARK: - - NVTrashable Stuff -
extension NVStoryManager {
	func trash(_ item: NVLinkable) {
		_trashed.append(item)
		_delegates.forEach{$0.onStoryTrashItem(item: item)}
	}
	
	func untrash(_ item: NVLinkable) {
		if let idx = _trashed.index(where: {$0.UUID == item.UUID}) {
			_trashed.remove(at: idx)
			_delegates.forEach{$0.onStoryUntrashItem(item: item)}
		}
	}
	
	public func emptyTrash() {
		// for all trashable items, actually DELETE them. Make delete private?
		print("Not yet implemented.")
	}
}



