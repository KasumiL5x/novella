//
//  Story.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import JavaScriptCore

class Story {
	// MARK: Javascript stuff
	let _jsContext: JSContext
	
	// MARK: Storywide Collections
	var _allIdentifiables: [Identifiable]
	var _allFolders: [Folder]
	var _allVariables: [Variable]
	var _allGraphs: [NVGraph]
	var _allLinks: [BaseLink]
	var _allNodes: [NVNode]
	
	// MARK: Local Collections
	var _folders: [Folder]
	var _graphs: [NVGraph]
	
	var _name: String
	
	init() {
		self._jsContext = JSContext()
		self._jsContext.exceptionHandler = { context, exception in
			if let ex = exception {
				print("JS Exception: \(ex.toString())")
			}
		}
		let consoleLogObject = unsafeBitCast(self.consoleLog, to: AnyObject.self)
		self._jsContext.setObject(consoleLogObject, forKeyedSubscript: "consoleLog" as (NSCopying & NSObjectProtocol))
//		_ = self._jsContext.evaluateScript("consoleLog(nil);")
		
		self._allIdentifiables = []
		self._allFolders = []
		self._allVariables = []
		self._allGraphs = []
		self._allLinks = []
		self._allNodes = []
		
		self._folders = []
		self._graphs = []
		
		self._name = ""
	}
	
	// MARK: Javascript stuff
	// TODO: Get/Set variables in JS
	let consoleLog: @convention(block) (String) -> Void = { logMessage in
		print("\nJS Console: \(logMessage)")
	}
	
	// MARK: Setup
	func setup() throws {
		throw Errors.notImplemented("Story::setup()")
	}
}

// MARK: Local Collection Functions
extension Story {
	// MARK: Folders
	func contains(folder: Folder) -> Bool {
		return _folders.contains(folder)
	}
	
	func containsFolderName(name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	@discardableResult
	func add(folder: Folder) throws -> Folder {
		// already a child
		if contains(folder: folder) {
			throw Errors.invalid("Tried to add a Folder but it already exists (\(folder._name) to story).")
		}
		// already contains same name
		if containsFolderName(name: folder._name) {
			throw Errors.nameTaken("Tried to add a Folder but its name was already in use (\(folder._name) to story).")
		}
		// now add
		_folders.append(folder)
		return folder
	}
	
	func remove(folder: Folder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw Errors.invalid("Tried to remove Folder (\(folder._name)) from story but it was not a child.")
		}
		_folders.remove(at: idx)
	}
	
	// MARK: FlowGraphs
	func contains(graph: NVGraph) -> Bool {
		return _graphs.contains(graph)
	}
	
	func containsGraphName(name: String) -> Bool {
		return _graphs.contains(where: {$0._name == name})
	}
	
	@discardableResult
	func add(graph: NVGraph) throws -> NVGraph {
		// already a child
		if contains(graph: graph) {
			throw Errors.invalid("Tried to add a FlowGraph but it already exists (\(graph._name) to story).")
		}
		// already contains same name
		if containsGraphName(name: graph._name) {
			throw Errors.nameTaken("Tried to add a FlowGraph but its name was already in use (\(graph._name) to story).")
		}
		// unparent first
		if graph._parent != nil {
			try graph._parent?.remove(graph: graph)
		}
		// now add
		graph._parent = nil
		_graphs.append(graph)
		return graph
	}
	
	func remove(graph: NVGraph) throws {
		guard let idx = _graphs.index(of: graph) else {
			throw Errors.invalid("Tried to remove FlowGraph (\(graph._name)) from story but it was not a child.")
		}
		_graphs.remove(at: idx)
	}
}

// MARK: Storywide Functions
extension Story {
	func findBy(uuid: String) -> Identifiable? {
		return _allIdentifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	@discardableResult
	func makeFolder(name: String, uuid: NSUUID?=nil) -> Folder {
		let folder = Folder(uuid: uuid != nil ? uuid! : NSUUID(), name: name)
		_allFolders.append(folder)
		_allIdentifiables.append(folder)
		return folder
	}
	
	@discardableResult
	func makeVariable(name: String, type: DataType, uuid: NSUUID?=nil) -> Variable {
		let variable = Variable(uuid: uuid != nil ? uuid! : NSUUID(), name: name, type: type)
		_allVariables.append(variable)
		_allIdentifiables.append(variable)
		return variable
	}
	
	@discardableResult
	func makeGraph(name: String, uuid: NSUUID?=nil) -> NVGraph {
		let graph = NVGraph(uuid: uuid != nil ? uuid! : NSUUID(), name: name, story: self)
		_allGraphs.append(graph)
		_allIdentifiables.append(graph)
		return graph
	}
	
	@discardableResult
	func makeLink(uuid: NSUUID?=nil) -> Link {
		let link = Link(uuid: uuid != nil ? uuid! : NSUUID(), story: self)
		_allLinks.append(link)
		_allIdentifiables.append(link)
		return link
	}
	@discardableResult
	func makeBranch(uuid: NSUUID?=nil) -> Branch {
		let branch = Branch(uuid: uuid != nil ? uuid! : NSUUID(), story: self)
		_allLinks.append(branch)
		_allIdentifiables.append(branch)
		return branch
	}
	@discardableResult
	func makeSwitch(uuid: NSUUID?=nil) -> Switch {
		let swtch = Switch(uuid: uuid != nil ? uuid! : NSUUID(), story: self)
		_allLinks.append(swtch)
		_allIdentifiables.append(swtch)
		return swtch
	}
	
	@discardableResult
	func makeDialog(uuid: NSUUID?=nil) -> Dialog {
		let dialog = Dialog(uuid: uuid != nil ? uuid! : NSUUID())
		_allNodes.append(dialog)
		_allIdentifiables.append(dialog)
		return dialog
	}
	
	func getLinksFrom(linkable: Linkable) -> [BaseLink] {
		return _allLinks.filter({$0._origin?.UUID == linkable.UUID})
	}
}

// MARK: Debug
extension Story {
	func debugPrint(global: Bool) {
		if global {
			print("\nStory (\(_name)):")
			
			// folders
			print("Folders (\(_allFolders.count)):")
			_allFolders.forEach({
				print("\tName: \($0._name)")
				print("\tUUID: \($0._uuid.uuidString)")
				print("\tSynopsis: \($0._synopsis)")
				print("\tParent: \($0._parent?._name ?? "none")")
				print("\tVariables (\($0._variables.count)):")
				$0._variables.forEach({print("\t\t\($0._uuid.uuidString)")})
				print("\tFolders (\($0._folders.count)):")
				$0._folders.forEach({print("\t\t\($0._uuid.uuidString)")})
				
				print("")
			})
			
			// variables
			print("\nVariables (\(_allVariables.count)):")
			_allVariables.forEach({
				print("\tName: \($0._name)")
				print("\tUUID: \($0._uuid.uuidString)")
				print("\tSynopsis: \($0._synopsis)")
				print("\tConstant: \($0._constant)")
				print("\tFolder: \($0._folder?._name ?? "none")")
				print("\tData Type: \($0.DataType)")
				print("\tValue: \($0._value)")
				print("\tInitial Value: \($0._initialValue)")
				
				print("")
			})
			
			// graphs
			print("\nGraphs (\(_allGraphs.count)):")
			_allGraphs.forEach({
				print("\tName: \($0._name)")
				print("\tUUID: \($0._uuid.uuidString)")
				print("\tGraphs (\($0._graphs.count)):")
				$0._graphs.forEach({print("\t\t\($0._name + "(" + $0._uuid.uuidString + ")")")})
				print("\tNodes (\($0._nodes.count))")
				$0._nodes.forEach({print("\t\t\($0._uuid.uuidString)")})
				print("\tLinks (\($0._links.count))")
				$0._links.forEach({print("\t\t\($0._uuid.uuidString)")})
				print("\tListeners (\($0._listeners.count))")
				$0._listeners.forEach({print("\t\t\($0._uuid.uuidString)")})
				print("\tExits (\($0._exits.count))")
				$0._exits.forEach({print("\t\t\($0._uuid.uuidString)")})
				print("\tEntry: \($0._entry?.UUID.uuidString ?? "none")")
				
				print("")
			})
			
			// nodes
			print("\nNodes (\(_allNodes.count)):")
			_allNodes.forEach({
				print("\tUUID: \($0._uuid.uuidString)")
				if let dlg = $0 as? Dialog {
					print("\tType: Dialog")
					print("\tContent: \(dlg._content)")
					print("\tPreview: \(dlg._preview)")
					print("\tDirections: \(dlg._directions)")
				} else if let _ = $0 as? Delivery {
					print("\tType: Delivery")
				} else if let _ = $0 as? Cutscene {
					print("\tType: Cutscene")
				} else if let _ = $0 as? Context {
					print("\tType: Context")
				}
				
				print("")
			})
			
			// links
			print("\nLinks (\(_allLinks.count)):")
			_allLinks.forEach({
				print("\tUUID: \($0._uuid.uuidString)")
				print("\tOrigin: \($0._origin?.UUID.uuidString ?? "none")")
				if let link = $0 as? Link {
					print("\tType: Link")
					print("\tDestination: \(link._transfer._destination?.UUID.uuidString ?? "none")")
				} else if let branch = $0 as? Branch {
					print("\tType: Branch")
					print("\tTrue Destination: \(branch._trueTransfer._destination?.UUID.uuidString ?? "none")")
					print("\tFalse Destination: \(branch._falseTransfer._destination?.UUID.uuidString ?? "none")")
				} else if let swtch = $0 as? Switch {
					print("\tType: Switch")
					print("\tVariable: \(swtch._variable?._uuid.uuidString ?? "none")")
					print("\(swtch._defaultTransfer._destination?.UUID.uuidString ?? "none")")
					print("\tValues (\(swtch._values.count)):")
					swtch._values.forEach({ (key: AnyHashable, value: Transfer) in
						print("\t\t\(key) -> \(value._destination?.UUID.uuidString ?? "none")")
					})
				}
				print("")
			})
			
			// story local folders and graphs
			print("\nLocal Folders (\(_folders.count)):")
			_folders.forEach({
				print("\tUUID: \($0._uuid.uuidString)")
				print("")
			})
			print("\nLocal Graphs (\(_graphs.count)):")
			_graphs.forEach({
				print("\tUUID: \($0._uuid.uuidString)")
				print("")
			})
		}
	}
}
