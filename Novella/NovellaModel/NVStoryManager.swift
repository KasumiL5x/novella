//
//  NVStoryManager.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

typealias JavascriptClosure = (JSContext) -> Void
typealias ObjectivecCompletionBlockString = @convention(block) () -> String

public class NVStoryManager {
	// MARK: - Variables -
	private var _story: NVStory!
	private var _identifiables: [NVObject]
	private var _folders: [NVFolder]
	private var _variables: [NVVariable]
	private var _graphs: [NVGraph]
	private var _links: [NVBaseLink]
	private var _nodes: [NVNode]
	private var _entities: [NVEntity]
	private var _trashed: [NVObject]
	private var _delegates: [NVStoryDelegate]
	internal var _jsContext: JSContext
	
	// MARK: - Properties -
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
	public var Entities: [NVEntity] {
		get{ return _entities }
	}
	public var TrashedItems: [NVObject] {
		get{ return _trashed }
	}
	
	// MARK: - Initialization -
	public init() {
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._entities = []
		self._trashed = []
		self._delegates = []
		self._jsContext = JSContext()
		self._story = NVStory(manager: self)
		
		setupJavascript()
	}
	
	// MARK: - Functions -
	
	// MARK: Generic
	public func addDelegate(_ delegate: NVStoryDelegate) {
		_delegates.append(delegate)
	}
	
	public func reset() {
		self._story = NVStory(manager: self)
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._entities = []
		self._trashed = []
		self._delegates = []
		self._jsContext = JSContext()
		
		setupJavascript()
	}
	
	public func prepareForReading() {
		// reset all variables to their initial value
		_variables.forEach { (variable) in
			variable.setValue(variable.InitialValue)
		}
	}
	
	func find(uuid: String) -> NVObject? {
		return _identifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	public func nameOf(object: NVObject?) -> String {
		switch object {
		case is NVNode:
			return (object as!  NVNode).Name
		case is NVGraph:
			return (object as! NVGraph).Name
		default:
			return ""
		}
	}
	
	public func getLinksFrom(_ object: NVObject) -> [NVBaseLink] {
		return _links.filter({$0.Origin.UUID == object.UUID})
	}
	
	public func getLinksTo(_ object: NVObject) -> [NVBaseLink] {
		return _links.filter({
			
			switch $0 {
			case is NVLink:
				if let dest = ($0 as! NVLink).Transfer.Destination {
					return dest.UUID == object.UUID
				}
			case is NVBranch:
				if let trueDest = ($0 as! NVBranch).TrueTransfer.Destination {
					return trueDest.UUID == object.UUID
				}
				if let falseDest = ($0 as! NVBranch).FalseTransfer.Destination {
					return falseDest.UUID == object.UUID
				}
			case is NVSwitch:
				NVLog.log("getLinksTo() doesn't yet handle Switch.", level: .warning)
			default:
				return false
			}
			
			return false
		})
	}
	
	// MARK: JavaScript Stuff
	func setupJavascript() {
		// javascript runtime error handling
		_jsContext.exceptionHandler = { (ctx, ex) in
			if let ex = ex {
				NVLog.log("JavaScript error: \(ex.toString())", level: .error)
			}
		}
		
		// function to print to the console from JS
		let nvLogObject = unsafeBitCast(self.js_nvlog, to: AnyObject.self)
		_jsContext.setObject(nvLogObject, forKeyedSubscript: "nvlog" as (NSCopying & NSObjectProtocol))
		
		// get variables by (first appearance of) name
		let js_getvar: @convention(block) (String) -> Any? = { [weak self](name) in
			for v in self!._variables {
				if name == NVPath.fullPathTo(v) {
					NVLog.log("JS requested variable: \(name).  Found and returning value: \(v.Value).", level: .debug)
					return v.Value
				}
			}
			
			NVLog.log("JS requested variable: \(name).  Could not find varible; returning nil.", level: .debug)
			return nil
		}
		_jsContext.setObject(js_getvar, forKeyedSubscript: "getvar" as (NSCopying & NSObjectProtocol))
		
		// set variables by (first appearange of) name
		let js_setvar: @convention(block) (String, Any) -> Void = { [weak self](name, value) in
			// find the given variable by name
			var variable: NVVariable? = nil
			for v in self!._variables {
				if name == NVPath.fullPathTo(v) {
					variable = v
				}
			}
			
			// safety check
			if variable == nil {
				NVLog.log("JS requested setting variable \"\(name)\" but was not found.", level: .debug)
				return
			}
			
			if !variable!.setValue(value) {
				NVLog.log("JS requested setting variable \"\(name)\" to value \"\(value)\" but it failed to do so.", level: .debug)
			}
		}
		_jsContext.setObject(js_setvar, forKeyedSubscript: "setvar" as (NSCopying & NSObjectProtocol))
		
	}
	
	let js_nvlog: @convention(block) (String) -> Void = { msg in
		NVLog.log("\nJavaScript Console: \(msg)", level: .info)
	}
}

// MARK: - Folders -
extension NVStoryManager {
	@discardableResult
	public func makeFolder(name: String, uuid: NSUUID?=nil) -> NVFolder {
		let folder = NVFolder(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_folders.append(folder)
		_identifiables.append(folder)
		
		NVLog.log("Created a new Folder (\(folder.UUID)).", level: .info)
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
			parent.remove(folder: folder)
		}

		// remove from story
		if _story.contains(folder: folder) {
			_story.remove(folder: folder)
		}

		// actual remove
		_folders.remove(at: _folders.index(of: folder)!)
		_identifiables.remove(at: _identifiables.index(of: folder)!)

		NVLog.log("Deleted Folder (\(folder.UUID))" + (deleteContents ? " and its contents." : "."), level: .info)
		_delegates.forEach{$0.onStoryDeleteFolder(folder: folder, contents: deleteContents)}
	}
}

// MARK: - Variables -
extension NVStoryManager {
	@discardableResult
	public func makeVariable(name: String, type: NVDataType, uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
		_variables.append(variable)
		_identifiables.append(variable)
		
		NVLog.log("Created a new Variable (\(variable.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeVariable(variable: variable)}
		return variable
	}
	
	public func delete(variable: NVVariable) {
		_folders.first(where: {$0.Variables.contains(variable)})?.remove(variable: variable)
		_variables.remove(at: _variables.index(of: variable)!)
		_identifiables.remove(at: _identifiables.index(of: variable)!)
		
		NVLog.log("Deleted Variable (\(variable.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryDeleteVariable(variable: variable)}
	}
}

// MARK: - Graphs -
extension NVStoryManager {
	@discardableResult
	public func makeGraph(name: String, uuid: NSUUID?=nil) -> NVGraph {
		let graph = NVGraph(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_graphs.append(graph)
		_identifiables.append(graph)
		
		NVLog.log("Created a new Graph (\(graph.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeGraph(graph: graph)}
		return graph
	}
	
	func delete(graph: NVGraph) {
		// note: duplicating lists as delete function modifies the internal lists
		
		// 1. remove from either story or its parent
		if _story.contains(graph: graph) {
			_story.remove(graph: graph)
		}
		graph.Parent?.remove(graph: graph)
		
		// 2. delete all of its nodes
		let nodes = graph.Nodes
		nodes.forEach{delete(node: $0)}
		
		// 3. delete all of its links
		let links = graph.Links
		links.forEach{delete(link: $0)}
		
		// 4. delete all listeners
		//TODO: Handle delete of listeners (technically NVNodes but in different lists).
		
		// 5. delete all exits
		// TODO: Handle delete of exits.
		
		// 6. delete all child graphs
		let graphs = graph.Graphs
		graphs.forEach{delete(graph: $0)}
		
		// 7. remove from graphs
		_graphs.remove(at: _graphs.index(of: graph)!)
		
		// 8. remove from identifiables
		_identifiables.remove(at: _identifiables.index(of: graph)!)
	
		// delegate
		NVLog.log("Deleted Graph (\(graph.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryDeleteGraph(graph: graph)}
	}
}

// MARK: - Links -
extension NVStoryManager {
	@discardableResult
	public func makeLink(origin: NVObject, uuid: NSUUID?=nil) -> NVLink {
		let link = NVLink(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(link)
		_identifiables.append(link)
		
		NVLog.log("Created a new Link (\(link.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeLink(link: link)}
		return link
	}
	
	@discardableResult
	public func makeBranch(origin: NVObject, uuid: NSUUID?=nil) -> NVBranch {
		let branch = NVBranch(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(branch)
		_identifiables.append(branch)
		
		NVLog.log("Created a new Branch (\(branch.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeBranch(branch: branch)}
		return branch
	}
	
	@discardableResult
	public func makeSwitch(origin: NVObject, uuid: NSUUID?=nil) -> NVSwitch {
		let swtch = NVSwitch(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(swtch)
		_identifiables.append(swtch)
		
		NVLog.log("Created a new Switch (\(swtch.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeSwitch(theSwitch: swtch)}
		return swtch
	}
	
	func delete(link: NVBaseLink) {
		// 1. remove from all graphs containing it
		_graphs.forEach { (graph) in
			if graph.contains(link: link) {
				graph.remove(link: link)
			}
		}
		
		// 2. remove from all links
		_links.remove(at: _links.index(of: link)!)
		
		// 3. remove from all identifiables
		_identifiables.remove(at: _identifiables.index(of: link)!)
		
		NVLog.log("Deleted Link (\(link.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryDeleteLink(link: link)}
	}
}

// MARK: - Nodes -
extension NVStoryManager {
	@discardableResult
	public func makeDialog(uuid: NSUUID?=nil) -> NVDialog {
		let dialog = NVDialog(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(dialog)
		_identifiables.append(dialog)
		
		NVLog.log("Created a new Dialog (\(dialog.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeDialog(dialog: dialog)}
		return dialog
	}
	
	@discardableResult
	public func makeDelivery(uuid: NSUUID?=nil) -> NVDelivery {
		let delivery = NVDelivery(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(delivery)
		_identifiables.append(delivery)
		
		NVLog.log("Created a new Delivery (\(delivery.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeDelivery(delivery: delivery)}
		return delivery
	}
	
	@discardableResult
	public func makeContext(uuid: NSUUID?=nil) -> NVContext {
		let context = NVContext(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(context)
		_identifiables.append(context)
		
		NVLog.log("Created a new Context (\(context.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeContext(context: context)}
		return context
	}
	
	func delete(node: NVNode) {
		// 1. remove from all graphs containing it
		_graphs.forEach { (graph) in
			if graph.contains(node: node) {
				graph.remove(node: node)
			}
		}
		
		// 2. nil destination of all links going to it
		getLinksTo(node).forEach { (link) in
			switch link {
			case is NVLink:
				(link as! NVLink).Transfer.Destination = nil
				
			case is NVBranch:
				let asBranch = link as! NVBranch
				if asBranch.TrueTransfer.Destination?.UUID == node.UUID {
					asBranch.TrueTransfer.Destination = nil
				}
				if asBranch.FalseTransfer.Destination?.UUID == node.UUID {
					asBranch.FalseTransfer.Destination = nil
				}
				
			case is NVSwitch:
				NVLog.log("delete(node) tried to remove Node from Switch but it is not yet implemented.", level: .warning)
				
			default:
				break
			}
		}
		
		// 3. delete (fully) any links originating at this node
		let originLinks = getLinksFrom(node)
		for ol in originLinks {
			delete(link: ol)
		}
		
		// 4. remove from all nodes
		_nodes.remove(at: _nodes.index(of: node)!)
		
		// 5. remove from all identifiables
		_identifiables.remove(at: _identifiables.index(of: node)!)
		
		NVLog.log("Deleted Node (\(node.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryDeleteNode(node: node)}
	}
}

// MARK: - Entities -
extension NVStoryManager {
	@discardableResult
	public func makeEntity(name: String, uuid: NSUUID?=nil) -> NVEntity {
		let entity = NVEntity(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		entity.Name = name
		_entities.append(entity)
		_identifiables.append(entity)
		
		NVLog.log("Created a new Entity (\(entity.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryMakeEntity(entity: entity)}
		return entity
	}
	
	func delete(entity: NVEntity) {
		// 1. remove from all entities
		_entities.remove(at: _entities.index(of: entity)!)
		
		// 2. remove from all identifiables
		_identifiables.remove(at: _identifiables.index(of: entity)!)
		
		NVLog.log("Deleted Entity (\(entity.UUID)).", level: .info)
		_delegates.forEach{$0.onStoryDeleteEntity(entity: entity)}
	}
	// handle in trash below
}

// MARK: - Trashing Stuff -
extension NVStoryManager {
	func trash(_ item: NVObject) {
		_trashed.append(item)
		
		NVLog.log("Object (\(item.UUID)) trashed.", level: .info)
		_delegates.forEach{$0.onStoryTrashObject(object: item)}
	}
	
	func untrash(_ item: NVObject) {
		if let idx = _trashed.index(of: item) {
			_trashed.remove(at: idx)
			
			NVLog.log("Object (\(item.UUID)) untrashed.", level: .info)
			_delegates.forEach{$0.onStoryUntrashObject(object: item)}
		}
	}
	
	public func emptyTrash() {
		for i in (0..<_trashed.count).reversed() {
			let curr = _trashed[i]
			switch curr {
			case is NVBaseLink:
				delete(link: curr as! NVBaseLink)
				_trashed.remove(at: i)
				
			case is NVNode:
				delete(node: curr as! NVNode)
				_trashed.remove(at: i)
				
			case is NVGraph:
				delete(graph: curr as! NVGraph)
				_trashed.remove(at: i)
				
			case is NVEntity:
				delete(entity: curr as! NVEntity)
				_trashed.remove(at: i)
				
			default:
				NVLog.log("Tried to untrash some unhandled object: \(curr.UUID.uuidString)", level: .warning)
			}
		}
	}
}



