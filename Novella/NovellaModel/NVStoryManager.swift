//
//  NVStoryManager.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

public class NVStoryManager: NSObject, NSCoding {
	// MARK: - - Variables -
	private var _story: NVStory!
	private var _identifiables: [NVIdentifiable]
	private var _folders: [NVFolder]
	private var _variables: [NVVariable]
	private var _graphs: [NVGraph]
	private var _links: [NVBaseLink]
	private var _nodes: [NVNode]
	private var _trashed: [NVLinkable]
	private var _delegates: [NVStoryDelegate]
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
	public override init() {
		self._identifiables = []
		self._folders = []
		self._variables = []
		self._graphs = []
		self._links = []
		self._nodes = []
		self._trashed = []
		self._delegates = []
		self._jsContext = JSContext()
		self._story = nil
		super.init()
		self._story = NVStory(manager: self)
		setupJavascript()
	}
	
	// MARK: Coding
	public required convenience init?(coder aDecoder: NSCoder) {
		// HACK: Made this convenience so that it can call the regular init first, setting up the JSContext for me since it cannot be en/decoded.
		self.init()
		
		self._story = aDecoder.decodeObject(forKey: "_story") as! NVStory
		self._identifiables = aDecoder.decodeObject(forKey: "_identifiables") as! [NVIdentifiable]
		self._folders = aDecoder.decodeObject(forKey: "_folders") as! [NVFolder]
		self._variables = aDecoder.decodeObject(forKey: "_variables") as! [NVVariable]
		self._graphs = aDecoder.decodeObject(forKey: "_graphs") as! [NVGraph]
		self._links = aDecoder.decodeObject(forKey: "_links") as! [NVBaseLink]
		self._nodes = aDecoder.decodeObject(forKey: "_nodes") as! [NVNode]
		self._trashed = aDecoder.decodeObject(forKey: "_trashed") as! [NVLinkable]
		self._delegates = [] // cannot en/decode elements that *may* not conform to NSCoding (it's likely that user delegates won't), so they must be RE-ADDED upon coding.
	}
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(_story, forKey: "_story")
		aCoder.encode(_identifiables, forKey: "_identifiables")
		aCoder.encode(_folders, forKey: "_folders")
		aCoder.encode(_variables, forKey: "_variables")
		aCoder.encode(_graphs, forKey: "_graphs")
		aCoder.encode(_links, forKey: "_links")
		aCoder.encode(_nodes, forKey: "_nodes")
		aCoder.encode(_trashed, forKey: "_trashed")
	}
	
	// MARK: Snapshotting
	public func snapshot() -> NVStoryManager {
		let archive = NSKeyedArchiver.archivedData(withRootObject: self)
		return NSKeyedUnarchiver.unarchiveObject(with: archive) as! NVStoryManager
	}
	public func restore(snapshot: NVStoryManager) {
		fatalError("Not yet implemented.")
	}
	
	// MARK: - - Generic Functions -
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
		let folder = NVFolder(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name)
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
		let variable = NVVariable(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
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
		let graph = NVGraph(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), name: name)
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
		let link = NVLink(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(link)
		_identifiables.append(link)
		
		_delegates.forEach{$0.onStoryMakeLink(link: link)}
		return link
	}
	
	@discardableResult
	public func makeBranch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVBranch {
		let branch = NVBranch(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(branch)
		_identifiables.append(branch)
		
		_delegates.forEach{$0.onStoryMakeBranch(branch: branch)}
		return branch
	}
	
	@discardableResult
	public func makeSwitch(origin: NVLinkable, uuid: NSUUID?=nil) -> NVSwitch {
		let swtch = NVSwitch(manager: self, uuid: uuid != nil ? uuid! : NSUUID(), origin: origin)
		_links.append(swtch)
		_identifiables.append(swtch)
		
		_delegates.forEach{$0.onStoryMakeSwitch(switch: swtch)}
		return swtch
	}
	
	public func delete(link: NVBaseLink) {
		// 1. remove from all graphs containing it
		_graphs.forEach { (graph) in
			if graph.contains(link: link) {
				try! graph.remove(link: link)
			}
		}
		
		// 2. remove from all links
		_links.remove(at: _links.index(of: link)!)
		
		// 3. remove from all identifiables
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == link.UUID})!)
		
		_delegates.forEach{$0.onStoryDeleteLink(link: link)}
	}
}

// MARK: - - Nodes -
extension NVStoryManager {
	@discardableResult
	public func makeDialog(uuid: NSUUID?=nil) -> NVDialog {
		let dialog = NVDialog(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(dialog)
		_identifiables.append(dialog)
		
		_delegates.forEach{$0.onStoryMakeDialog(dialog: dialog)}
		return dialog
	}
	
	@discardableResult
	public func makeDelivery(uuid: NSUUID?=nil) -> NVDelivery {
		let delivery = NVDelivery(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(delivery)
		_identifiables.append(delivery)
		
		_delegates.forEach{$0.onStoryMakeDelivery(delivery: delivery)}
		return delivery
	}
	
	@discardableResult
	public func makeContext(uuid: NSUUID?=nil) -> NVContext {
		let context = NVContext(manager: self, uuid: uuid != nil ? uuid! : NSUUID())
		_nodes.append(context)
		_identifiables.append(context)
		
		_delegates.forEach{$0.onStoryMakeContext(context: context)}
		return context
	}
	
	func delete(node: NVNode) {
		// 1. remove from all graphs containing it
		_graphs.forEach { (graph) in
			if graph.contains(node: node) {
				try! graph.remove(node: node)
			}
		}
		
		// 2. nil destination of all links going to it
		getLinksTo(node).forEach { (link) in
			switch link {
			case is NVLink:
				(link as! NVLink).setDestination(dest: nil)
				
			case is NVBranch:
				let asBranch = link as! NVBranch
				if asBranch.TrueTransfer.Destination?.UUID == node.UUID {
					asBranch.setTrueDestination(dest: nil)
				}
				if asBranch.FalseTransfer.Destination?.UUID == node.UUID {
					asBranch.setFalseDestination(dest: nil)
				}
				
			case is NVSwitch:
				print("NVStoryManager::delete(node): Tried to remove node form NVSwitch but is not yet implemented.")
				
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
		_identifiables.remove(at: _identifiables.index(where: {$0.UUID == node.UUID})!)
		
		_delegates.forEach{$0.onStoryDeleteNode(node: node)}
	}
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
		for i in (0..<_trashed.count).reversed() {
			let curr = _trashed[i]
			switch curr {
			case is NVBaseLink:
				delete(link: curr as! NVBaseLink)
				_trashed.remove(at: i)
				
			case is NVNode:
				delete(node: curr as! NVNode)
				_trashed.remove(at: i)
				
			default:
				print("Tried to untrash some unhandled object: \(curr)")
			}
		}
	}
}



