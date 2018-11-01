//
//  Document.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa
import SwiftyJSON

class Document: NSDocument {
	// MARK: - Additional Non-Model Data
	// position of anything in the UI (usually nodes, branches, switches, etc.)
	var Positions: [NSUUID:CGPoint] = [:] {
		didSet { updateChangeCount(.changeDone) }
	}
	// image name for entities
	var EntityImageNames: [NSUUID:String] = [:] {
		didSet{
			updateChangeCount(.changeDone)
		}
	}
	
	
	// MARK: - Properties
	private(set) var Story: NVStory = NVStory()
	
	override init() {
		super.init()
		Story.addDelegate(self)
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		let jsonString = self.toJSON()
		if jsonString.isEmpty {
			NVLog.log("Tried to write JSON but the resulting string was empty.", level: .warning)
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		guard let jsonData = jsonString.data(using: .utf8) else {
			NVLog.log("Failed to get data from JSON string.", level: .warning)
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		return jsonData
	}

	override func read(from data: Data, ofType typeName: String) throws {
		guard self.fromJSON(data: data) else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
	}
}

extension Document {
	typealias JSONDict = [String:Any]
	
	func fromJSON(data: Data) -> Bool {
		guard let json = try? JSON(data: data) else {
			NVLog.log("Failed to parse JSON data.", level: .warning)
			return false
		}
		
		Swift.print(json)

		
		// read variables
		for variable in json["variables"].arrayValue {
			let id = NSUUID(uuidString: variable["id"].stringValue)!
			let name = variable["name"].stringValue
			let entry = Story.makeVariable(name: name, uuid: id)
			entry.Synopsis = variable["synopsis"].stringValue
			entry.Constant = variable["constant"].boolValue
			
			if let asBool = variable["initial"].bool {
				entry.InitialValue = NVValue(.boolean(asBool))
			} else if let asInt = variable["initial"].int32 {
				entry.InitialValue = NVValue(.integer(asInt))
			} else if let asDub = variable["initial"].double {
				entry.InitialValue = NVValue(.double(asDub))
			}
		}
		
		// read folders
		for folder in json["folders"].arrayValue {
			let id = NSUUID(uuidString: folder["id"].stringValue)!
			let name = folder["name"].stringValue
			let entry = Story.makeFolder(name: name, uuid: id)
			entry.Synopsis = folder["synopsis"].stringValue
			
			// link variables to this folder by uuid
			for child in folder["variables"].arrayValue {
				if let found = Story.find(uuid: child.stringValue) as? NVVariable {
					entry.add(variable: found)
				} else {
					NVLog.log("Unable to find Variable by ID (\(child.stringValue)) when linking to Folder (\(id.uuidString)).", level: .warning)
				}
			}
		}
		
		// link folders to folders by id
		for folder in json["folders"].arrayValue {
			let id = folder["id"].stringValue
			guard let thisFolder = Story.find(uuid: id) as? NVFolder else {
				NVLog.log("Tried to link Folder (\(id)) but couldn't find it!", level: .warning)
				continue
			}
			
			for child in folder["folders"].arrayValue {
				if let found = Story.find(uuid: child.stringValue) as? NVFolder {
					thisFolder.add(folder: found)
				} else {
					NVLog.log("Unable to find Folder by ID (\(child.stringValue)) when linking to Folder (\(id)).", level: .warning)
				}
			}
		}
		
		// read entities
		for entity in json["entities"].arrayValue {
			let id = NSUUID(uuidString: entity["id"].stringValue)!
			let ent = Story.makeEntity(uuid: id)
			ent.Name = entity["name"].stringValue
			ent.Synopsis = entity["synopsis"].stringValue
			EntityImageNames[id] = entity["image"].stringValue
		}
		
		// read nodes
		for node in json["nodes"].arrayValue {
			let id = NSUUID(uuidString: node["id"].stringValue)!
			let name = node["name"].stringValue
			let pos = NSMakePoint(CGFloat(node["pos"]["x"].floatValue), CGFloat(node["pos"]["y"].floatValue))
			Positions[id] = pos
			
			switch node["type"].stringValue {
			case "dialog":
				let dialog = Story.makeDialog(uuid: id)
				dialog.Name = name
				dialog.Content = node["content"].stringValue
				dialog.Directions = node["directions"].stringValue
				dialog.Preview = node["preview"].stringValue
				
				let instigatorID = node["instigator"].stringValue
				if !instigatorID.isEmpty {
					if let instigator = Story.find(uuid: node["instigator"].stringValue) as? NVEntity {
						dialog.Instigator = instigator
					} else {
						NVLog.log("Unable to find Entity by ID (\(node["instigator"].stringValue)) when setting Dialog (\(id.uuidString)) instigator.", level: .warning)
					}
				}
				
			case "delivery":
				let delivery = Story.makeDelivery(uuid: id)
				delivery.Name = name
				delivery.Content = node["content"].stringValue
				delivery.Directions = node["directions"].stringValue
				delivery.Preview = node["preview"].stringValue
				
			case "context":
				let context = Story.makeContext(uuid: id)
				context.Name = name
				context.Content = node["content"].stringValue
				
			default:
				NVLog.log("Encountered unknown NVNode type during import (\(node["type"].stringValue)).", level: .warning)
			}
		}
		
		// read branches w/o transfers (as linkables may not yet be loaded)
		for branch in json["branches"].arrayValue {
			let id = NSUUID(uuidString: branch["id"].stringValue)!
			let entry = Story.makeBranch(uuid: id)
			
			let pos = NSMakePoint(CGFloat(branch["pos"]["x"].floatValue), CGFloat(branch["pos"]["y"].floatValue))
			Positions[id] = pos
			
			entry.Condition.JavaScript = branch["cond"]["js"].stringValue
		}
		
		// read switches w/o transfers
		for swtch in json["switches"].arrayValue {
			let id = NSUUID(uuidString: swtch["id"].stringValue)!
			let entry = Story.makeSwitch(uuid: id)
			
			let pos = NSMakePoint(CGFloat(swtch["pos"]["x"].floatValue), CGFloat(swtch["pos"]["y"].floatValue))
			Positions[id] = pos
			
			entry.Variable = Story.find(uuid: swtch["var"].stringValue) as? NVVariable // if it fails nil is assigned which is fine
			
			// default option
			var defaultObj = swtch["default"]
			if let asBool = defaultObj["value"].bool {
				entry.DefaultOption.value = NVValue(.boolean(asBool))
			} else if let asInt = defaultObj["value"].int32 {
				entry.DefaultOption.value = NVValue(.integer(asInt))
			} else if let asDub = defaultObj["value"].double {
				entry.DefaultOption.value = NVValue(.double(asDub))
			}
			
			// other options
			for option in swtch["options"].arrayValue {
				if let asBool = option["value"].bool {
					entry.addOption(withValue: NVValue(.boolean(asBool)))
				} else if let asInt = option["value"].int32 {
					entry.addOption(withValue: NVValue(.integer(asInt)))
				} else if let asDub = option["value"].double {
					entry.addOption(withValue: NVValue(.double(asDub)))
				}
			}
		}
		
		// link branch transfers now that everything is loaded
		for branch in json["branches"].arrayValue {
			let id = branch["id"].stringValue
			guard let thisBranch = Story.find(uuid: id) as? NVBranch else {
				NVLog.log("Tried to link Branch (\(id)) but couldn't find it!", level: .warning)
				continue
			}
			
			if let ttransfer = branch["ttransfer"].dictionary {
				let destID = ttransfer["dest"]!.stringValue
				if !destID.isEmpty {
					if let destFound = Story.find(uuid: destID) as? NVLinkable {
						thisBranch.TrueTransfer.Destination = destFound
					} else {
						NVLog.log("Unable to find Linkable by ID (\(destID)) when setting a Branch (\(id)) true transfer destination.", level: .warning)
					}
				}
				thisBranch.TrueTransfer.Function.JavaScript = ttransfer["func"]!["js"].stringValue
			}
			
			if let ftransfer = branch["ftransfer"].dictionary {
				let destID = ftransfer["dest"]!.stringValue
				if !destID.isEmpty {
					if let destFound = Story.find(uuid: destID) as? NVLinkable {
						thisBranch.FalseTransfer.Destination = destFound
					} else {
						NVLog.log("Unable to find Linkable by ID (\(destID)) when setting a Branch (\(id)) false transfer destination.", level: .warning)
					}
				}
				thisBranch.FalseTransfer.Function.JavaScript = ftransfer["func"]!["js"].stringValue
			}
		}
		
		// link switch transfers
		for swtch in json["switches"].arrayValue {
			let id = swtch["id"].stringValue
			guard let thisSwitch = Story.find(uuid: id) as? NVSwitch else {
				NVLog.log("Tried to link Switch (\(id)) but couldn't find it!", level: .warning)
				continue
			}
			
			// default option transfer
			if let defaultTransfer = swtch["default"]["transfer"].dictionary {
				let destID = defaultTransfer["dest"]!.stringValue
				if !destID.isEmpty {
					if let destFound = Story.find(uuid: destID) as? NVLinkable {
						thisSwitch.DefaultOption.transfer.Destination = destFound
					} else {
						NVLog.log("Unable to find Linkable by ID (\(destID)) when setting a Switch (\(id)) default option transfer destination.", level: .warning)
					}
				}
				thisSwitch.DefaultOption.transfer.Function.JavaScript = defaultTransfer["func"]!["js"].stringValue
			}
			
			// other option transfers
			var switchIndex: Int = 0 // hack: I have no 'id' for the options, so i'm relying on the index of this dictionary being the same as the last read, and hoping the NVSwitch option array has the same order...
			for option in swtch["options"].arrayValue {
				if let optionTransfer = option["transfer"].dictionary {
					let destID = optionTransfer["dest"]!.stringValue
					if !destID.isEmpty {
						if let destFound = Story.find(uuid: destID) as? NVLinkable {
							thisSwitch.Options[switchIndex].transfer.Destination = destFound
						} else {
							NVLog.log("Unable to find Linkable by ID (\(destID)) when setting a Switch (\(id)) option transfer destination.", level: .warning)
						}
					}
					thisSwitch.Options[switchIndex].transfer.Function.JavaScript = optionTransfer["func"]!["js"].stringValue
				}
				
				switchIndex += 1
			}
		}
		
		// read links
		for link in json["links"].arrayValue {
			let id = NSUUID(uuidString: link["id"].stringValue)!
			let originID = link["origin"].stringValue
			guard let originFound = Story.find(uuid: originID) as? NVLinkable else {
				NVLog.log("Unable to find Linkable by ID (\(originID)) when creating a Link (\(id.uuidString)).", level: .warning)
				continue
			}
			
			let entry = Story.makeLink(origin: originFound, uuid: id)
			entry.PreCondition.JavaScript = link["precond"]["js"].stringValue
			
			if let transfer = link["transfer"].dictionary {
				let destID = transfer["dest"]!.stringValue
				if !destID.isEmpty {
					if let destFound = Story.find(uuid: destID) as? NVLinkable {
						entry.Transfer.Destination = destFound
					} else {
						NVLog.log("Unable to find Linkable by ID (\(destID)) when setting a Link (\(id.uuidString)) transfer destination.", level: .warning)
					}
				}
				entry.Transfer.Function.JavaScript = transfer["func"]!["js"].stringValue
			}
		}
		
		// read graphs
		for graph in json["graphs"].arrayValue {
			let id = NSUUID(uuidString: graph["id"].stringValue)!
			let name = graph["name"].stringValue
			let entry = Story.makeGraph(name: name, uuid: id)
			
			// link nodes by id
			for child in graph["nodes"].arrayValue {
				if let childFound = Story.find(uuid: child.stringValue) as? NVNode {
					entry.add(node: childFound)
				} else {
					NVLog.log("Unable to find Node by ID (\(child.stringValue)) when adding to Graph (\(id.uuidString)).", level: .warning)
				}
			}
			
			// link links by id
			for child in graph["links"].arrayValue {
				if let childFound = Story.find(uuid: child.stringValue) as? NVLink {
					entry.add(link: childFound)
				} else {
					NVLog.log("Unable to find Link by ID (\(child.stringValue)) when adding to Graph (\(id.uuidString)).", level: .warning)
				}
			}
			
			// link branches by id
			for child in graph["branches"].arrayValue {
				if let childFound = Story.find(uuid: child.stringValue) as? NVBranch {
					entry.add(branch: childFound)
				} else {
					NVLog.log("Unable to find Branch by ID (\(child.stringValue)) when adding to Graph (\(id.uuidString)).", level: .warning)
				}
			}
			
			// link switches by id
			for child in graph["switches"].arrayValue {
				if let childFound = Story.find(uuid: child.stringValue) as? NVSwitch {
					entry.add(swtch: childFound)
				} else {
					NVLog.log("Unable to find Switch by ID (\(child.stringValue)) when adding to Graph (\(id.uuidString)).", level: .warning)
				}
			}
			
			let entryID = graph["entry"].stringValue
			if !entryID.isEmpty {
				if let entryFound = Story.find(uuid: entryID) as? NVNode {
					entry.Entry = entryFound
				} else {
					NVLog.log("Unable to find Node by ID (\(entryID)) when setting a Graph (\(id.uuidString)) entry.", level: .warning)
				}
			}
		}
		
		// link graphs to graphs by id
		for graph in json["graphs"].arrayValue {
			let id = graph["id"].stringValue
			guard let thisGraph = Story.find(uuid: id) as? NVGraph else {
				NVLog.log("Tried to link Graph (\(id)) but couldn't find it!", level: .warning)
				continue
			}
			
			for child in graph["graphs"].arrayValue {
				if let childFound = Story.find(uuid: child.stringValue) as? NVGraph {
					thisGraph.add(graph: childFound)
				} else {
					NVLog.log("Unable to find Graph by ID (\(child.stringValue)) when adding to Graph (\(id)).", level: .warning)
				}
			}
		}
		
		// process main graph (separate from other graphs)
		let mainGraph = json["maingraph"]
		for child in mainGraph["nodes"].arrayValue {
			if let childFound = Story.find(uuid: child.stringValue) as? NVNode {
				Story.MainGraph?.add(node: childFound)
			} else {
				NVLog.log("Unable to find Node by ID (\(child.stringValue)) when adding to the main Graph.", level: .warning)
			}
		}
		for child in mainGraph["links"].arrayValue {
			if let childFound = Story.find(uuid: child.stringValue) as? NVLink {
				Story.MainGraph?.add(link: childFound)
			} else {
				NVLog.log("Unable to find Link by ID (\(child.stringValue)) when adding to the main Graph.", level: .warning)
			}
		}
		for child in mainGraph["branches"].arrayValue {
			if let childFound = Story.find(uuid: child.stringValue) as? NVBranch {
				Story.MainGraph?.add(branch: childFound)
			} else {
				NVLog.log("Unable to find Branch by ID (\(child.stringValue)) when adding to the main Graph.", level: .warning)
			}
		}
		for child in mainGraph["switches"].arrayValue {
			if let childFound = Story.find(uuid: child.stringValue) as? NVSwitch {
				Story.MainGraph?.add(swtch: childFound)
			} else {
				NVLog.log("Unable to find Switch by ID (\(child.stringValue)) when adding to the main Graph.", level: .warning)
			}
		}
		for child in mainGraph["graphs"].arrayValue {
			if let childFound = Story.find(uuid: child.stringValue) as? NVGraph {
				Story.MainGraph?.add(graph: childFound)
			} else {
				NVLog.log("Unable to find Graph by ID (\(child.stringValue)) when adding to the main Graph.", level: .warning)
			}
		}
		let mgEntryID = mainGraph["entry"].stringValue
		if !mgEntryID.isEmpty {
			if let entryFound = Story.find(uuid: mgEntryID) as? NVNode {
				Story.MainGraph?.Entry = entryFound
			} else {
				NVLog.log("Unable to find Node by ID (\(mgEntryID)) when setting the main Graph entry.", level: .warning)
			}
		}
		
		// process mainfolder (separate from other folders)
		let mainFolder = json["mainfolder"]
		Story.MainFolder?.Synopsis = mainFolder["synopsis"].stringValue
		for child in mainFolder["variables"].arrayValue {
			if let found = Story.find(uuid: child.stringValue) as? NVVariable {
				Story.MainFolder?.add(variable: found)
			} else {
				NVLog.log("Unable to find Variable by ID (\(child.stringValue)) when linking to main Folder.", level: .warning)
			}
		}
		for child in mainFolder["folders"].arrayValue {
			if let found = Story.find(uuid: child.stringValue) as? NVFolder {
				Story.MainFolder?.add(folder: found)
			} else {
				NVLog.log("Unable to find Folder by ID (\(child.stringValue)) when linking to main Folder.", level: .warning)
			}
		}
		
		return true
	}
	
	func toJSON() -> String {
		var root: JSONDict = [:]
		
		// add folders
		var folders: [JSONDict] = []
		Story.Folders.forEach { (folder) in
			var entry: JSONDict = [:]
			entry["id"] = folder.ID.uuidString
			entry["name"] = folder.Name
			entry["synopsis"] = folder.Synopsis
			entry["folders"] = folder.Folders.map{$0.ID.uuidString}
			entry["variables"] = folder.Variables.map{$0.ID.uuidString}
			folders.append(entry)
		}
		root["folders"] = folders
		
		// add variables
		var variables: [JSONDict] = []
		Story.Variables.forEach { (variable) in
			var entry: JSONDict = [:]
			entry["id"] = variable.ID.uuidString
			entry["name"] = variable.Name
			entry["synopsis"] = variable.Synopsis
			entry["constant"] = variable.Constant
			switch variable.InitialValue.Raw.type {
			case .boolean:
				entry["initial"] = variable.InitialValue.Raw.asBool
			case .integer:
				entry["initial"] = variable.InitialValue.Raw.asInt
			case .double:
				entry["initial"] = variable.InitialValue.Raw.asDouble
			}
			variables.append(entry)
		}
		root["variables"] = variables
		
		// add links
		var links: [JSONDict] = []
		Story.Links.forEach { (link) in
			var entry: JSONDict = [:]
			entry["id"] = link.ID.uuidString
			entry["origin"] = link.Origin.ID.uuidString
			
			var precond: JSONDict = [:]
				precond["js"] = link.PreCondition.JavaScript
			entry["precond"] = precond
			
			var transfer: JSONDict = [:]
				transfer["dest"] = link.Transfer.Destination?.ID.uuidString ?? ""
				var function: JSONDict = [:]
					function["js"] = link.Transfer.Function.JavaScript
				transfer["func"] = function
			entry["transfer"] = transfer
			links.append(entry)
		}
		root["links"] = links
		
		// add branches
		var branches: [JSONDict] = []
		Story.Branches.forEach { (branch) in
			var entry: JSONDict = [:]
			entry["id"] = branch.ID.uuidString
			let pos = Positions[branch.ID] ?? CGPoint.zero
			entry["pos"] = [
				"x": pos.x,
				"y": pos.y
			]

			var cond: JSONDict = [:]
				cond["js"] = branch.Condition.JavaScript
			entry["cond"] = cond

			var trueTransfer: JSONDict = [:]
				trueTransfer["dest"] = branch.TrueTransfer.Destination?.ID.uuidString ?? ""
				var trueFunc: JSONDict = [:]
					trueFunc["js"] = branch.TrueTransfer.Function.JavaScript
				trueTransfer["func"] = trueFunc
			entry["ttransfer"] = trueTransfer

			var falseTransfer: JSONDict = [:]
				falseTransfer["dest"] = branch.FalseTransfer.Destination?.ID.uuidString ?? ""
				var falseFunc: JSONDict = [:]
					falseFunc["js"] = branch.FalseTransfer.Function.JavaScript
				falseTransfer["func"] = falseFunc
			entry["ftransfer"] = falseTransfer
			branches.append(entry)
		}
		root["branches"] = branches
		
		// add switches
		var switches: [JSONDict] = []
		Story.Switches.forEach { (swtch) in
			var entry: JSONDict = [:]
			entry["id"] = swtch.ID.uuidString
			
			let pos = Positions[swtch.ID] ?? CGPoint.zero
			entry["pos"] = [
				"x": pos.x,
				"y": pos.y
			]
			
			entry["var"] = swtch.Variable?.ID.uuidString ?? ""
			
			// export default option
			var defaultOption: JSONDict = [:]
				switch swtch.DefaultOption.value.Raw.type {
				case .boolean:
					defaultOption["value"] = swtch.DefaultOption.value.Raw.asBool
				case .integer:
					defaultOption["value"] = swtch.DefaultOption.value.Raw.asInt
				case .double:
					defaultOption["value"] = swtch.DefaultOption.value.Raw.asDouble
				}
				var defaultTransfer: JSONDict = [:]
					defaultTransfer["dest"] = swtch.DefaultOption.transfer.Destination?.ID.uuidString ?? ""
					var defaultFunc: JSONDict = [:]
						defaultFunc["js"] = swtch.DefaultOption.transfer.Function.JavaScript
					defaultTransfer["func"] = defaultFunc
				defaultOption["transfer"] = defaultTransfer
			entry["default"] = defaultOption
			
			// export all options
			var options: [JSONDict] = []
			for option in swtch.Options {
				var opt: JSONDict = [:]
				switch option.value.Raw.type {
				case .boolean:
					opt["value"] = option.value.Raw.asBool
				case .integer:
					opt["value"] = option.value.Raw.asInt
				case .double:
					opt["value"] = option.value.Raw.asDouble
				}
				var optTransfer: JSONDict = [:]
					optTransfer["dest"] = option.transfer.Destination?.ID.uuidString ?? ""
					var optFunc: JSONDict = [:]
						optFunc["js"] = option.transfer.Function.JavaScript
					optTransfer["func"] = optFunc
				opt["transfer"] = optTransfer
				options.append(opt)
			}
			entry["options"] = options
			
			switches.append(entry)
		}
		root["switches"] = switches
		
		// add nodes
		var nodes: [JSONDict] = []
		Story.Nodes.forEach { (node) in
			var entry: JSONDict = [:]
			entry["id"] = node.ID.uuidString
			entry["name"] = node.Name
			
			let pos = Positions[node.ID] ?? CGPoint.zero
			entry["pos"] = [
				"x": pos.x,
				"y": pos.y
			]
			
			switch node {
			case let asDialog as NVDialog:
				entry["type"] = "dialog"
				entry["content"] = asDialog.Content
				entry["directions"] = asDialog.Directions
				entry["preview"] = asDialog.Preview
				entry["instigator"] = asDialog.Instigator?.ID.uuidString ?? ""
			case let asDelivery as NVDelivery:
				entry["type"] = "delivery"
				entry["content"] = asDelivery.Content
				entry["directions"] = asDelivery.Directions
				entry["preview"] = asDelivery.Preview
			case let asContext as NVContext:
				entry["type"] = "context"
				entry["content"] = asContext.Content
			default:
				NVLog.log("Encountered unknown NVNode type during export.", level: .warning)
			}
			nodes.append(entry)
		}
		root["nodes"] = nodes
		
		// add graphs
		var graphs: [JSONDict] = []
		Story.Graphs.forEach { (graph) in
			var entry: JSONDict = [:]
			entry["id"] = graph.ID.uuidString
			entry["name"] = graph.Name
			entry["entry"] = graph.Entry?.ID.uuidString ?? ""
			entry["graphs"] = graph.Graphs.map{$0.ID.uuidString}
			entry["nodes"] = graph.Nodes.map{$0.ID.uuidString}
			entry["links"] = graph.Links.map{$0.ID.uuidString}
			entry["branches"] = graph.Branches.map{$0.ID.uuidString}
			entry["switches"] = graph.Switches.map{$0.ID.uuidString}
			graphs.append(entry)
		}
		root["graphs"] = graphs
		
		// add main graph
		var mainGraph: JSONDict = [:]
		mainGraph["id"] = Story.MainGraph!.ID.uuidString
		mainGraph["name"] = Story.MainGraph!.Name
		mainGraph["entry"] = Story.MainGraph!.Entry?.ID.uuidString ?? ""
		mainGraph["graphs"] = Story.MainGraph!.Graphs.map{$0.ID.uuidString}
		mainGraph["nodes"] = Story.MainGraph!.Nodes.map{$0.ID.uuidString}
		mainGraph["links"] = Story.MainGraph!.Links.map{$0.ID.uuidString}
		mainGraph["branches"] = Story.MainGraph!.Branches.map{$0.ID.uuidString}
		mainGraph["switches"] = Story.MainGraph!.Switches.map{$0.ID.uuidString}
		root["maingraph"] = mainGraph
		
		// add main folder
		var mainFolder: JSONDict = [:]
		mainFolder["id"] = Story.MainFolder!.ID.uuidString
		mainFolder["name"] = Story.MainFolder!.Name
		mainFolder["synopsis"] = Story.MainFolder!.Synopsis
		mainFolder["folders"] = Story.MainFolder!.Folders.map{$0.ID.uuidString}
		mainFolder["variables"] = Story.MainFolder!.Variables.map{$0.ID.uuidString}
		root["mainfolder"] = mainFolder
		
		// add entities
		var entities: [JSONDict] = []
		Story.Entities.forEach { (entity) in
			var entry: JSONDict = [:]
			entry["id"] = entity.ID.uuidString
			entry["name"] = entity.Name
			entry["synopsis"] = entity.Synopsis
			entry["image"] = EntityImageNames[entity.ID] ?? ""
			entities.append(entry)
		}
		root["entities"] = entities
		
		if !JSONSerialization.isValidJSONObject(root) {
			Swift.print("JSON object wasn't valid.")
			return ""
		}
		
		guard let jsonData = try? JSONSerialization.data(withJSONObject: root, options: .prettyPrinted) else {
			Swift.print("JSON data couldn't be formed.")
			return ""
		}
		
		let jsonString = String(data: jsonData, encoding: .utf8)!
		return jsonString
	}
}

extension Document: NVStoryDelegate {
	func nvVariableDidRename(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvVariableSynopsisDidChange(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvVariableConstantDidChange(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvVariableValueDidChange(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvVariableInitialValueDidChange(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvFolderDidRename(folder: NVFolder) { updateChangeCount(.changeDone) }
	func nvFolderSynopsisDidChange(folder: NVFolder) { updateChangeCount(.changeDone) }
	func nvFolderDidAddFolder(parent: NVFolder, child: NVFolder) { updateChangeCount(.changeDone) }
	func nvFolderDidRemoveFolder(parent: NVFolder, child: NVFolder) { updateChangeCount(.changeDone) }
	func nvFolderDidAddVariable(parent: NVFolder, child: NVVariable) { updateChangeCount(.changeDone) }
	func nvFolderDidRemoveVariable(parent: NVFolder, child: NVVariable) { updateChangeCount(.changeDone) }
	func nvTransferDestinationDidSet(transfer: NVTransfer) { updateChangeCount(.changeDone) }
	func nvStoryDidCreateGraph(graph: NVGraph) { updateChangeCount(.changeDone) }
	func nvStoryDidCreateFolder(folder: NVFolder) { updateChangeCount(.changeDone) }
	func nvStoryDidCreateLink(link: NVLink) { updateChangeCount(.changeDone) }
	func nvStoryDidCreateBranch(branch: NVBranch) {
		updateChangeCount(.changeDone)
		if Positions[branch.ID] == nil {
			Positions[branch.ID] = CGPoint.zero
		}
	}
	func nvStoryDidCreateSwitch(swtch: NVSwitch) {
		updateChangeCount(.changeDone)
		if Positions[swtch.ID] == nil {
			Positions[swtch.ID] = CGPoint.zero
		}
	}
	func nvStoryDidCreateDialog(dialog: NVDialog) {
		updateChangeCount(.changeDone)
		if Positions[dialog.ID] == nil {
			Positions[dialog.ID] = CGPoint.zero
		}
	}
	func nvStoryDidCreateDelivery(delivery: NVDelivery) {
		updateChangeCount(.changeDone)
		if Positions[delivery.ID] == nil {
			Positions[delivery.ID] = CGPoint.zero
		}
	}
	func nvStoryDidCreateContext(context: NVContext) {
		updateChangeCount(.changeDone)
		if Positions[context.ID] == nil {
			Positions[context.ID] = CGPoint.zero
		}
	}
	func nvStoryDidCreateEntity(entity: NVEntity) {
		updateChangeCount(.changeDone)
		if EntityImageNames[entity.ID] != nil {
			EntityImageNames[entity.ID] = ""
		}
	}
	func nvStoryDidCreateVariable(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteFolder(folder: NVFolder) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteVariable(variable: NVVariable) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteEntity(entity: NVEntity) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteNode(node: NVNode) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteLink(link: NVLink) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteBranch(branch: NVBranch) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteSwitch(swtch: NVSwitch) { updateChangeCount(.changeDone) }
	func nvStoryDidDeleteGraph(graph: NVGraph) { updateChangeCount(.changeDone) }
	func nvGraphDidRename(graph: NVGraph) { updateChangeCount(.changeDone) }
	func nvGraphDidAddGraph(parent: NVGraph, child: NVGraph) { updateChangeCount(.changeDone) }
	func nvGraphDidRemoveGraph(parent: NVGraph, child: NVGraph) { updateChangeCount(.changeDone) }
	func nvGraphDidAddNode(parent: NVGraph, child: NVNode) { updateChangeCount(.changeDone) }
	func nvGraphDidRemoveNode(parent: NVGraph, child: NVNode) { updateChangeCount(.changeDone) }
	func nvGraphDidSetEntry(graph: NVGraph, entry: NVNode?) { updateChangeCount(.changeDone) }
	func nvGraphDidAddLink(graph: NVGraph, link: NVLink) { updateChangeCount(.changeDone) }
	func nvGraphDidRemoveLink(graph: NVGraph, link: NVLink) { updateChangeCount(.changeDone) }
	func nvGraphDidAddBranch(graph: NVGraph, branch: NVBranch) { updateChangeCount(.changeDone) }
	func nvGraphDidRemoveBranch(graph: NVGraph, branch: NVBranch) { updateChangeCount(.changeDone) }
	func nvGraphDidAddSwitch(graph: NVGraph, swtch: NVSwitch) { updateChangeCount(.changeDone) }
	func nvGraphDidRemoveSwitch(graph: NVGraph, swtch: NVSwitch) { updateChangeCount(.changeDone) }
	func nvNodeDidRename(node: NVNode) { updateChangeCount(.changeDone) }
	func nvDialogContentDidChange(dialog: NVDialog) { updateChangeCount(.changeDone) }
	func nvDialogDirectionsDidChange(dialog: NVDialog) { updateChangeCount(.changeDone) }
	func nvDialogPreviewDidChange(dialog: NVDialog) { updateChangeCount(.changeDone) }
	func nvDialogInstigatorDidChange(dialog: NVDialog) { updateChangeCount(.changeDone) }
	func nvDeliveryContentDidChange(delivery: NVDelivery) { updateChangeCount(.changeDone) }
	func nvDeliveryDirectionsDidChange(delivery: NVDelivery) { updateChangeCount(.changeDone) }
	func nvDeliveryPreviewDidChange(delivery: NVDelivery) { updateChangeCount(.changeDone) }
	func nvContextContentDidChange(context: NVContext) { updateChangeCount(.changeDone) }
	func nvConditionDidUpdate(condition: NVCondition) { updateChangeCount(.changeDone) }
	func nvFunctionDidUpdate(function: NVFunction) { updateChangeCount(.changeDone) }
	func nvSwitchVariableDidChange(swtch: NVSwitch) { updateChangeCount(.changeDone) }
	func nvSwitchDidAddOption(swtch: NVSwitch, option: NVSwitchOption) { updateChangeCount(.changeDone) }
	func nvSwitchDidRemoveOption(swtch: NVSwitch, option: NVSwitchOption) { updateChangeCount(.changeDone) }
	func nvEntityDidRename(entity: NVEntity) { updateChangeCount(.changeDone) }
	func nvEntitySynopsisDidChange(entity: NVEntity) { updateChangeCount(.changeDone) }
}
