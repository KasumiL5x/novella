//
//  NVStory.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation
import JavaScriptCore

class NVStory {
	// MARK: - Variables
	private var _identifiables: [NVIdentifiable]
	
	// MARK: - Properties
	private(set) var Delegates: [NVStoryDelegate] = []
	private(set) var MainGraph: NVGraph? = nil
	private(set) var MainFolder: NVFolder? = nil
	private(set) var JVM: JSContext = JSContext()
	
	// MARK: - Properties
	var Graphs: [NVGraph] {
		get{ return _identifiables.filter{$0 is NVGraph} as! [NVGraph] }
	}
	var Folders: [NVFolder] {
		get{ return _identifiables.filter{$0 is NVFolder} as! [NVFolder] }
	}
	var Links: [NVLink] {
		get{ return _identifiables.filter{$0 is NVLink} as! [NVLink] }
	}
	var Branches: [NVBranch] {
		get{ return _identifiables.filter{$0 is NVBranch} as! [NVBranch] }
	}
	var Switches: [NVSwitch] {
		get{ return _identifiables.filter{$0 is NVSwitch} as! [NVSwitch] }
	}
	var Variables: [NVVariable] {
		get{ return _identifiables.filter{$0 is NVVariable} as! [NVVariable] }
	}
	var Nodes: [NVNode] {
		get{ return _identifiables.filter{$0 is NVNode} as! [NVNode] }
	}
	var Entities: [NVEntity] {
		get{ return _identifiables.filter{$0 is NVEntity} as! [NVEntity] }
	}
	
	// MARK: - Initialization
	init() {
		self._identifiables = []
		// uuid doesn't matter and we don't want them in the identifiables list.
		self.MainGraph = NVGraph(id: NSUUID(), story: self, name: "main")
		self.MainFolder = NVFolder(id: NSUUID(), story: self, name: "main")
		
		setupJavaScript()
	}
	
	// MARK: - JavaScript
	func setupJavaScript() {
		// runtime error handling
		JVM.exceptionHandler = { (ctx, ex) in
			if let ex = ex {
				NVLog.log("JavaScript error: \(ex.toString() ?? "")", level: .error)
			}
		}
		
		// print to console from JS
		let js_nvprint: @convention(block) (String) -> Void = { msg in
			NVLog.log("\nJavaScript Console: \(msg)", level: .info)
		}
		JVM.setObject(js_nvprint, forKeyedSubscript: "nvprint" as (NSCopying & NSObjectProtocol))
		
		// get bool variable
		let js_getbool: @convention(block) (String) -> Any? = { [weak self](name) in
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					NVLog.log("JavaScript requested boolean: \(name).  Found and returning value: \(v.Value.Raw.asBool).", level: .debug)
					return v.Value.Raw.asBool
				}
			}
			NVLog.log("JavaScript requested boolean: \(name).  Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getbool, forKeyedSubscript: "getbool" as (NSCopying & NSObjectProtocol))
		
		// get int variable
		let js_getint: @convention(block) (String) -> Any? = { [weak self](name) in
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					NVLog.log("JavaScript requested integer: \(name). Found and returning value: \(v.Value.Raw.asInt).", level: .debug)
					return v.Value.Raw.asInt
				}
			}
			NVLog.log("JavaScript requested integer: \(name). Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getint, forKeyedSubscript: "getint" as (NSCopying & NSObjectProtocol))
		
		// get double variable
		let js_getdub: @convention(block) (String) -> Any? = { [weak self](name) in
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					NVLog.log("JavaScript requested double: \(name). Found and returning value: \(v.Value.Raw.asDouble).", level: .debug)
					return v.Value.Raw.asDouble
				}
			}
			NVLog.log("JavaScript requested double: \(name). Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getdub, forKeyedSubscript: "getdub" as (NSCopying & NSObjectProtocol))
		
		// set bool variable
		let js_setbool: @convention(block) (String, Bool) -> Void = { [weak self](name, value) in
			var variable: NVVariable? = nil
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					variable = v
					break
				}
			}
			guard let unwrapped = variable else {
				NVLog.log("JavaScript requested setting bool: \(name). Not found; ignoring.", level: .debug)
				return
			}
			unwrapped.Value = NVValue(.boolean(value))
			NVLog.log("JavaScript requested setting bool: \(name). Found and set to: \(value).", level: .debug)
		}
		JVM.setObject(js_setbool, forKeyedSubscript: "setbool" as (NSCopying & NSObjectProtocol))
		
		// set int variable
		let js_setint: @convention(block) (String, Int32) -> Void = { [weak self](name, value) in
			var variable: NVVariable? = nil
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					variable = v
					break
				}
			}
			guard let unwrapped = variable else {
				NVLog.log("JavaScript requested setting integer: \(name). Not found; ignoring.", level: .debug)
				return
			}
			unwrapped.Value = NVValue(.integer(value))
			NVLog.log("JavaScript requested setting integer: \(name). Found and set to: \(value).", level: .debug)
		}
		JVM.setObject(js_setint, forKeyedSubscript: "setint" as (NSCopying & NSObjectProtocol))
		
		// set double variable
		let js_setdub: @convention(block) (String, Double) -> Void = { [weak self](name, value) in
			var variable: NVVariable? = nil
			for v in self!.Variables {
				if name == NVPath.fullPath(v) {
					variable = v
					break
				}
			}
			guard let unwrapped = variable else {
				NVLog.log("JavaScript requested setting double: \(name). Not found; ignoring.", level: .debug)
				return
			}
			unwrapped.Value = NVValue(.double(value))
			NVLog.log("JavaScript requested setting double: \(name). Found and set to: \(value).", level: .debug)
		}
		JVM.setObject(js_setdub, forKeyedSubscript: "setdub" as (NSCopying & NSObjectProtocol))
	}
	
	// MARK: - Delgates
	func addDelegate(_ delegate: NVStoryDelegate) {
		Delegates.append(delegate)
	}
	
	// MARK: - Reading Stuff
	func prepareForReading() {
		// reset variable values
		Variables.forEach { (variable) in
			variable.Value = variable.InitialValue
		}
	}
	
	// MARK: - Findng Stuff
	func find(uuid: String) -> NVIdentifiable? {
		return _identifiables.first(where: {$0.ID.uuidString == uuid})
	}
	func getLinksFrom(linkable: NVLinkable) -> [NVLink] {
		return Links.filter({$0.Origin.ID == linkable.ID})
	}
	
	// MARK: - Creation
	@discardableResult func makeGraph(name: String, uuid: NSUUID?=nil) -> NVGraph {
		let graph = NVGraph(id: uuid ?? NSUUID(), story: self, name: name)
		_identifiables.append(graph)
		
		Delegates.forEach{$0.nvStoryDidCreateGraph(graph: graph)}
		return graph
	}
	@discardableResult func makeFolder(name: String, uuid: NSUUID?=nil) -> NVFolder {
		let folder = NVFolder(id: uuid ?? NSUUID(), story: self, name: name)
		_identifiables.append(folder)
		
		Delegates.forEach{$0.nvStoryDidCreateFolder(folder: folder)}
		return folder
	}
	@discardableResult func makeLink(origin: NVLinkable, uuid: NSUUID?=nil) -> NVLink {
		let link = NVLink(id: uuid ?? NSUUID(), story: self, origin: origin)
		_identifiables.append(link)
		
		Delegates.forEach{$0.nvStoryDidCreateLink(link: link)}
		return link
	}
	@discardableResult func makeBranch(uuid: NSUUID?=nil) -> NVBranch {
		let branch = NVBranch(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(branch)
		
		Delegates.forEach{$0.nvStoryDidCreateBranch(branch: branch)}
		return branch
	}
	@discardableResult func makeSwitch(uuid: NSUUID?=nil) -> NVSwitch {
		let swtch = NVSwitch(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(swtch)
		
		Delegates.forEach{$0.nvStoryDidCreateSwitch(swtch: swtch)}
		return swtch
	}
	@discardableResult func makeDialog(uuid: NSUUID?=nil) -> NVDialog {
		let dialog = NVDialog(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(dialog)
		
		Delegates.forEach{$0.nvStoryDidCreateDialog(dialog: dialog)}
		return dialog
	}
	@discardableResult func makeDelivery(uuid: NSUUID?=nil) -> NVDelivery {
		let delivery = NVDelivery(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(delivery)
		
		Delegates.forEach{$0.nvStoryDidCreateDelivery(delivery: delivery)}
		return delivery
	}
	@discardableResult func makeContext(uuid: NSUUID?=nil) -> NVContext {
		let context = NVContext(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(context)
		
		Delegates.forEach{$0.nvStoryDidCreateContext(context: context)}
		return context
	}
	@discardableResult func makeEntity(uuid: NSUUID?=nil) -> NVEntity {
		let entity = NVEntity(id: uuid ?? NSUUID(), story: self)
		_identifiables.append(entity)
		
		Delegates.forEach{$0.nvStoryDidCreateEntity(entity: entity)}
		return entity
	}
	@discardableResult func makeVariable(name: String, uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(id: uuid ?? NSUUID(), story: self, name: name)
		_identifiables.append(variable)
		
		Delegates.forEach{$0.nvStoryDidCreateVariable(variable: variable)}
		return variable
	}
	
	// MARK: - Deletion
	func deleteGraph(graph: NVGraph) {
		// cannot delete main graph
		if graph == MainGraph {
			NVLog.log("Tried to delete MainGraph but that is not allowed!", level: .warning)
			return
		}
		
		// delete all of its contained graphs
		for (_, graph) in graph.Graphs.enumerated().reversed() {
			deleteGraph(graph: graph)
		}
		
		// delete all of its contained nodes
		for (_, node) in graph.Nodes.enumerated().reversed() {
			deleteNode(node: node)
		}
		
		// delete all of its contained links
		for (_, link) in graph.Links.enumerated().reversed() {
			deleteLink(link: link)
		}
		
		// delete all of its contained branches
		for (_, branch) in graph.Branches.enumerated().reversed() {
			deleteBranch(branch: branch)
		}
		
		// delete all of its contained switches
		for (_, swtch) in graph.Switches.enumerated().reversed() {
			deleteSwitch(swtch: swtch)
		}
		
		// remove from parent
		graph.Parent?.remove(graph: graph)
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == graph.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Graph (\(graph.ID)) and its contents.", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteGraph(graph: graph)}
	}
	func deleteFolder(folder: NVFolder) {
		// cannot delete main folder
		if folder == MainFolder {
			NVLog.log("Tried to delete MainFolder but that is not allowed!", level: .warning)
			return
		}
		
		// delete all child folders
		for (_, child) in folder.Folders.enumerated().reversed() {
			deleteFolder(folder: child)
		}
		
		// delete all child variables
		for (_, child) in folder.Variables.enumerated().reversed() {
			deleteVariable(variable: child)
		}
		
		// remove from parent
		folder.removeFromParent()
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == folder.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Folder (\(folder.ID)) and its contents.", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteFolder(folder: folder)}
	}
	func deleteLink(link: NVLink) {
		// remove from all graphs containing it
		Graphs.forEach { (graph) in
			if graph.contains(link: link) {
				graph.remove(link: link)
			}
		}
		// main graph
		if MainGraph?.contains(link: link) ?? false {
			MainGraph?.remove(link: link)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == link.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Link (\(link.ID)).", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteLink(link: link)}
	}
	func deleteBranch(branch: NVBranch) {
		// remove from all graphs containing it
		Graphs.forEach { (graph) in
			if graph.contains(branch: branch) {
				graph.remove(branch: branch)
			}
		}
		// main graph
		if MainGraph?.contains(branch: branch) ?? false {
			MainGraph?.remove(branch: branch)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == branch.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Branch (\(branch.ID)).", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteBranch(branch: branch)}
	}
	func deleteSwitch(swtch: NVSwitch) {
		// remove from all graphs containing it
		Graphs.forEach { (graph) in
			if graph.contains(swtch: swtch) {
				graph.remove(swtch: swtch)
			}
		}
		// main graph
		if MainGraph?.contains(swtch: swtch) ?? false {
			MainGraph?.remove(swtch: swtch)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == swtch.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Switch (\(swtch.ID)).", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteSwitch(swtch: swtch)}
	}
	func deleteNode(node: NVNode) {
		// remove from graphs containing it
		Graphs.forEach{ (graph) in
			if graph.contains(node: node) {
				graph.remove(node: node)
			}
		}
		// main graph
		if MainGraph?.contains(node: node) ?? false {
			MainGraph?.remove(node: node)
		}
		
		// nil any graph entry points
		Graphs.forEach { (graph) in
			if graph.Entry == node {
				graph.Entry = nil
			}
		}
		// main graph
		if MainGraph?.Entry == node {
			MainGraph?.Entry = nil
		}
		
		// nil any transfer destinations going to it
		Links.forEach { (link) in
			if link.Transfer.Destination?.ID == node.ID {
				link.Transfer.Destination = nil
			}
		}
		Branches.forEach { (branch) in
			if branch.TrueTransfer.Destination?.ID == node.ID {
				branch.TrueTransfer.Destination = nil
			}
			if branch.FalseTransfer.Destination?.ID == node.ID {
				branch.FalseTransfer.Destination = nil
			}
		}
		Switches.forEach { (swtch) in
			if swtch.DefaultOption.transfer.Destination?.ID == node.ID {
				swtch.DefaultOption.transfer.Destination = nil
			}
			swtch.Options.forEach({ (option) in
				if option.transfer.Destination?.ID == node.ID {
					option.transfer.Destination = nil
				}
			})
		}
		
		// DELETE any links originating at it
		for (_, link) in Links.enumerated().reversed() {
			if link.Origin.ID == node.ID {
				deleteLink(link: link)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == node.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Node (\(node.ID)).", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteNode(node: node)}
	}
	func deleteEntity(entity: NVEntity) {
		// if any dialog instigators are this entity, nil them
		(_identifiables.filter{$0 is NVDialog} as! [NVDialog]).forEach { (dlg) in
			if dlg.Instigator == entity {
				dlg.Instigator = nil
			}
		}
		
		print("TODO: When adding Entities as instigators (etc) to other elements, don't forget to remove them here.")
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == entity.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Entity (\(entity.ID))", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteEntity(entity: entity)}
	}
	func deleteVariable(variable: NVVariable) {
		// remove from parent folder
		variable._parent?.remove(variable: variable)
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.ID == variable.ID}) {
			_identifiables.remove(at: idx)
		}
		
		// print and delegate
		NVLog.log("Deleted Variable (\(variable.ID))", level: .info)
		Delegates.forEach{$0.nvStoryDidDeleteVariable(variable: variable)}
	}
}

