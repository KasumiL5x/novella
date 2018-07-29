//
//  NVStoryManager+JSON.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JSONSchema
import SwiftyJSON

typealias JSONDict = [String:Any]

// MARK: - - Save -
extension NVStoryManager {
	public func toJSON() -> String {
		var root: JSONDict = [:]

		// add all folders
		var folders: [JSONDict] = []
		Folders.forEach{ (curr) in
			var entry: JSONDict = [:]
			entry["name"] = curr.Name
			entry["uuid"] = curr.UUID.uuidString
			entry["variables"] = curr.Variables.map({$0.UUID.uuidString})
			entry["subfolders"] = curr.Folders.map({$0.UUID.uuidString})
			folders.append(entry)
		}
		root["folders"] = folders
		
		// add all variables
		var variables: [JSONDict] = []
		Variables.forEach{ (curr) in
			var entry: JSONDict = [:]
			entry["name"] = curr.Name
			entry["uuid"] = curr.UUID.uuidString
			entry["synopsis"] = curr.Synopsis
			entry["datatype"] = curr.DataType.stringValue
			entry["constant"] = curr.IsConstant
			entry["initialValue"] = curr.InitialValue
			entry["value"] = curr.Value
			variables.append(entry)
		}
		root["variables"] = variables
		
		// add all entities
		var entities: [JSONDict] = []
		Entities.forEach { (curr) in
			var entry: JSONDict = [:]
			entry["name"] = curr.Name
			entry["uuid"] = curr.UUID.uuidString
			entry["image"] = curr.ImageName
			entities.append(entry)
		}
		root["entities"] = entities
		
		// add all graphs
		var graphs: [JSONDict] = []
		Graphs.forEach { (curr) in
			var entry: JSONDict = [:]
			entry["name"] = curr.Name
			entry["uuid"] = curr.UUID.uuidString
			entry["entry"] = curr._entry?.UUID.uuidString ?? ""
			entry["position"] = [
				"x": curr.Position.x,
				"y": curr.Position.y
			]
			entry["subgraphs"] = curr._graphs.map({$0.UUID.uuidString})
			entry["nodes"] = curr._nodes.map({$0.UUID.uuidString})
			entry["links"] = curr._links.map({$0.UUID.uuidString})
			entry["listeners"] = curr._listeners.map({$0.UUID.uuidString})
			graphs.append(entry)
		}
		root["graphs"] = graphs
		
		// add all links
		var links: [JSONDict] = []
		Links.forEach{ (curr) in
			var entry: JSONDict = [:]
			entry["uuid"] = curr.UUID.uuidString
			entry["origin"] = curr.Origin.UUID.uuidString
			
			if let asLink = curr as? NVLink {
				entry["linktype"] = "link"
				
				var precondition: JSONDict = [:]
				precondition["jscode"] = asLink.PreCondition.Javascript
				entry["precondition"] = precondition
				
				var transfer: JSONDict = [:]
				transfer["destination"] = asLink.Transfer.Destination?.UUID.uuidString ?? ""
					var function: JSONDict = [:]
					function["jscode"] = asLink.Transfer.Function.Javascript
					transfer["function"] = function
				entry["transfer"] = transfer
			}
			else if let asBranch = curr as? NVBranch {
				entry["linktype"] = "branch"
				
				var precondition: JSONDict = [:]
				precondition["jscode"] = asBranch.PreCondition.Javascript
				entry["precondition"] = precondition
				
				var condition: JSONDict = [:]
				condition["jscode"] = asBranch.Condition.Javascript
				entry["condition"] = condition
				
				var ttransfer: JSONDict = [:]
				ttransfer["destination"] = asBranch.TrueTransfer.Destination?.UUID.uuidString ?? ""
					var tfunction: JSONDict = [:]
					tfunction["jscode"] = asBranch.TrueTransfer.Function.Javascript
					ttransfer["function"] = tfunction
				entry["ttransfer"] = ttransfer
				
				var ftransfer: JSONDict = [:]
				ftransfer["destination"] = asBranch.FalseTransfer.Destination?.UUID.uuidString ?? ""
					var ffunction: JSONDict = [:]
					ffunction["jscode"] = asBranch.FalseTransfer.Function.Javascript
					ftransfer["function"] = ffunction
				entry["ftransfer"] = ftransfer
			}
			else if let asSwitch = curr as? NVSwitch {
				entry["linktype"] = "switch"
				
				var precondition: JSONDict = [:]
				precondition["jscode"] = ""//asSwitch.PreCondition.Javascript // TODO: Add precondition to switch.
				entry["precondition"] = precondition
				
				var dtransfer: JSONDict = [:]
				dtransfer["destination"] = asSwitch.DefaultTransfer.Destination?.UUID.uuidString ?? ""
					var dfunction: JSONDict = [:]
					dfunction["jscode"] = asSwitch.DefaultTransfer.Function.Javascript
					dtransfer["function"] = dfunction
				entry["dtransfer"] = dtransfer
				
				// TODO: The rest of Switches.
			}
			else {
				NVLog.log("NVStoryManager::toJSON(): Encountered NVBaseLink while exporting.  This should never happen.", level: .warning)
			}
			
			links.append(entry)
		}
		root["links"] = links
		
		// add all nodes
		var nodes: [JSONDict] = []
		Nodes.forEach{ (curr) in
			var entry: JSONDict = [:]
			entry["uuid"] = curr.UUID.uuidString
			entry["name"] = curr.Name
			entry["size"] = curr.Size.rawValue
			
			entry["position"] = [
				"x": curr.Position.x,
				"y": curr.Position.y
			]
			
			if let asDialog = curr as? NVDialog {
				entry["nodetype"] = "dialog"
				entry["speaker"] = asDialog.Speaker?.UUID.uuidString ?? ""
				entry["content"] = asDialog.Content
				entry["preview"] = asDialog.Preview
				entry["directions"] = asDialog.Directions
			}
			
			if let asDelivery = curr as? NVDelivery {
				entry["nodetype"] = "delivery"
				entry["content"] = asDelivery.Content
				entry["preview"] = asDelivery.Preview
				entry["directions"] = asDelivery.Directions
			}
			
			if let _ = curr as? NVContext {
				entry["nodetype"] = "context"
			}
			
			nodes.append(entry)
		}
		root["nodes"] = nodes
		
		// add folders and graphs (uuid) for story
		var storyEntry: JSONDict = [:]
		storyEntry["folders"] = Story.Folders.map({$0.UUID.uuidString})
		storyEntry["graphs"] = Story.Graphs.map({$0.UUID.uuidString})
		storyEntry["name"] = Story.Name
		root["story"] = storyEntry
		
		// check if the root object is valid JSON
		if !JSONSerialization.isValidJSONObject(root) {
			NVLog.log("NVStoryManager::toJSON(): Root object cannot form valid JSON.", level: .warning)
			return ""
		}
		
		// test against schema
		let schema = Schema(NVStoryManager.JSON_SCHEMA)
		let validated = schema.validate(root)
		if !validated.valid {
			NVLog.log("NVStoryManager::toJSON(): Failed to validate root against Schema.", level: .warning)
			validated.errors?.forEach({print($0)})
			return ""
		}
		
		// get a JSON string
		let json = JSON(root)
		guard let str = json.rawString(.utf8, options: .prettyPrinted) else {
			NVLog.log("NVStoryManager::toJSON(): Failed to serialize root into JSON.", level: .warning)
			return ""
		}
		return str
	}
}

// MARK: - - Load -
extension NVStoryManager {
	public static func fromJSON(str: String) -> NVStoryManager? {
		// get Data from string
		guard let data = str.data(using: .utf8)  else {
			NVLog.log("NVStoryManager::fromJSON(): Failed to get Data from JSON string.", level: .warning)
			return nil
		}
		
		// parse using SwiftyJSON
		let json: JSON
		do { json = try JSON(data: data) } catch {
			NVLog.log("NVStoryManager::fromJSON(): Failed to parse JSON.", level: .warning)
			return nil
		}
		
		// test against schema
		let schema = Schema(NVStoryManager.JSON_SCHEMA)
		let validated = schema.validate(json.object) // json.object is the root object
		if !validated.valid {
			NVLog.log("NVStoryManager::fromJSON(): Failed to validate JSON against schema.", level: .warning)
			validated.errors?.forEach({NVLog.log($0, level: .warning)})
			return nil
		}
		
		let storyManager = NVStoryManager()
		
		// 1. read all variables
		for curr in json["variables"].arrayValue {
			let dataType = NVDataType.fromString(str: curr["datatype"].string!)
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			let variable = storyManager.makeVariable(name: curr["name"].string!, type: dataType, uuid: uuid)
			
			if let synopsis = curr["synopsis"].string {
				variable.Synopsis = synopsis
			}
			
			if let constant = curr["constant"].bool {
				variable.IsConstant = constant
			}
			
			let value = curr["value"]
			let initialValue = curr["initialValue"]
			switch variable.DataType {
			case .boolean:
				if value != JSON.null {
					variable.setValue(value.bool!)
				}
				if initialValue != JSON.null {
					variable.setInitialValue(initialValue.bool!)
				}
				break
			case .integer:
				if value != JSON.null {
					variable.setValue(value.int!)
				}
				if initialValue != JSON.null {
					variable.setInitialValue(initialValue.int!)
				}
				break
			case .double:
				if value != JSON.null {
					variable.setValue(value.double!)
				}
				if initialValue != JSON.null {
					variable.setInitialValue(initialValue.double!)
				}
				break
			}
		}
		
		// 2. read all entities
		for curr in json["entities"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			let entity = storyManager.makeEntity(name: curr["name"].string!, uuid: uuid)
			if let imageName = curr["image"].string {
				entity.ImageName = imageName
			}
		}
		
		// 2. read all folders
		for curr in json["folders"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			let folder = storyManager.makeFolder(name: curr["name"].string!, uuid: uuid)
			
			if let synopsis = curr["synopsis"].string {
				folder.Synopsis = synopsis
			}
			
			// 2.1 link variables to folders by uuid
			for child in curr["variables"].arrayValue {
				if let variable = storyManager.find(uuid: child.string!) as? NVVariable {
					folder.add(variable: variable)
				} else {
					NVLog.log("NVStoryManager::fromJSON(): Unable to find Variable by UUID (\(child.string!) when adding to Folder (\(uuid.uuidString)).", level: .warning)
				}
			}
		}
		
		// 2.2 link subfolders to folders by uuid
		for curr in json["folders"].arrayValue {
			let folder = storyManager.find(uuid: curr["uuid"].string!) as! NVFolder
			for child in curr["subfolders"].arrayValue {
				if let subfolder = storyManager.find(uuid: child.string!) as? NVFolder {
					 folder.add(folder: subfolder)
				} else {
					NVLog.log("NVStoryManager::fromJSON(): Unable to find Folder by UUID (\(child.string!)) when adding to Folder (\(curr["uuid"].string!)).", level: .warning)
				}
			}
		}
		
		// 3. read all nodes
		for curr in json["nodes"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			
			let name = curr["name"].string
			
			let posX = curr["position"]["x"].float!
			let posY = curr["position"]["y"].float!
			
			var sizeEnum: NVNode.SizeType? = nil
			if let sizeIndex = curr["size"].int {
				sizeEnum = NVNode.SizeType(rawValue: sizeIndex)
				if sizeEnum == nil {
					NVLog.log("NVStoryManager::fromJSON(): Given node size failed to map to the NVNode.SizeType enum.  The index was\(sizeIndex).", level: .warning)
				}
			}
			
			switch curr["nodetype"].string! {
			case "dialog":
				let dialog = storyManager.makeDialog(uuid: uuid)
				dialog.Position = NSMakePoint(CGFloat(posX), CGFloat(posY))
				if sizeEnum != nil {
					dialog.Size = sizeEnum!
				}
				if name != nil {
					dialog.Name = name!
				}
				if let speakerUUID = curr["speaker"].string {
					if !speakerUUID.isEmpty {
						if let speakerEntity = storyManager.find(uuid: speakerUUID) as? NVEntity {
							dialog.Speaker = speakerEntity
						} else {
							NVLog.log("NVStoryManager::fromJSON(): Unable to find Entity by UUID (\(speakerUUID)) when setting Dialog's speaker (\(uuid.uuidString))", level: .warning)
						}
					}
				}
				if let content = curr["content"].string {
					dialog.Content = content
				}
				if let preview = curr["preview"].string {
					dialog.Preview = preview
				}
				if let directions = curr["directions"].string {
					dialog.Directions = directions
				}
				
			case "delivery":
				let delivery = storyManager.makeDelivery(uuid: uuid)
				delivery.Position = NSMakePoint(CGFloat(posX), CGFloat(posY))
				if sizeEnum != nil {
					delivery.Size = sizeEnum!
				}
				if name != nil {
					delivery.Name = name!
				}
				if let content = curr["content"].string {
					delivery.Content = content
				}
				if let preview = curr["preview"].string {
					delivery.Preview = preview
				}
				if let directions = curr["directions"].string {
					delivery.Directions = directions
				}
				
			case "cutscene":
				NVLog.log("NVStoryManager::fromJSON(): Encountered Cutscene but it is not yet implemented.", level: .warning)
				
			case "context":
				let context = storyManager.makeContext(uuid: uuid)
				if sizeEnum != nil {
					context.Size = sizeEnum!
				}
				context.Position = NSMakePoint(CGFloat(posX), CGFloat(posY))
				if name != nil {
					context.Name = name!
				}
				
			default:
				NVLog.log("NVStoryManager::fromJSON(): Encountered invalid node type (\(curr["nodetype"].string!))", level: .warning)
			}
		}
		
		// 4. read all listeners
		// TODO: Not yet implemented.
		
		// 5. read all exits
		// TODO: Not yet implemented.
		
		// 6. read all graphs
		for curr in json["graphs"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let graph = storyManager.makeGraph(name: curr["name"].string!, uuid: uuid)
			
			// position
			let posX = curr["position"]["x"].float!
			let posY = curr["position"]["y"].float!
			graph.Position = NSMakePoint(CGFloat(posX), CGFloat(posY))
			
			// 6.1 link all nodes by uuid
			for child in curr["nodes"].arrayValue {
				if let node = storyManager.find(uuid: child.string!) as? NVNode {
					graph.add(node: node)
				} else {
					NVLog.log("NVStoryManager::fromJSON(): Unable to find Node by UUID (\(child.string!) when adding to Graph (\(uuid.uuidString)).", level: .warning)
				}
			}
			
			// 6.2 link all listeners by UUID
			// TODO: Once listeners are parsed.
		}
		
		// 6.4 link all subgraphs by uuid
		for curr in json["graphs"].arrayValue {
			let graph = storyManager.find(uuid: curr["uuid"].string!) as! NVGraph
			for child in curr["subgraphs"].arrayValue {
				if let subgraph = storyManager.find(uuid: child.string!) as? NVGraph {
					graph.add(graph: subgraph)
				} else {
					NVLog.log("NVStoryManager::fromJSON(): Unable to find Graph by UUID (\(child.string!)) when adding to Graph (\(curr["uuid"].string!)).", level: .warning)
				}
			}
		}
		
		// 6.5 link all entry points by uuid (done after as an entry could be a subgraph)
		for curr in json["graphs"].arrayValue {
			let graph = storyManager.find(uuid: curr["uuid"].string!) as! NVGraph
			if let entry = curr["entry"].string {
				if !entry.isEmpty {
					if let object = storyManager.find(uuid: entry) {
						graph.setEntry(object)
					} else {
						NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(entry)) when setting Graph's entry (\(graph.UUID.uuidString)).", level: .warning)
					}
				}
			}
		}
		
		// 7. read all links
		for curr in json["links"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			
			let originID = curr["origin"].string!
			guard let origin = storyManager.find(uuid: originID) else {
				NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(originID)) when creating BaseLink (\(uuid.uuidString)).  Link will NOT be created.", level: .warning)
				continue // skips the link entirely if this error occurs
			}
			
			switch curr["linktype"].string! {
			case "link":
				let link = storyManager.makeLink(origin: origin, uuid: uuid)
				
				if let precondition = curr["precondition"].dictionary {
					link.PreCondition.Javascript = precondition["jscode"]!.string!
				}
				
				if let transfer = curr["transfer"].dictionary {
					let transferDestination = transfer["destination"]!.string!
					if !transferDestination.isEmpty {
						if let destination = storyManager.find(uuid: transferDestination) {
							link.setDestination(dest: destination)
						} else {
							NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(transfer["destination"]!.string!)) when setting a Link's Transfer's destination (\(uuid.uuidString)).", level: .warning)
						}
					}
					
					if let function = transfer["function"]?.dictionary {
						link.Transfer.Function.Javascript = function["jscode"]!.string!
					}
				}

			case "branch":
				let branch = storyManager.makeBranch(origin: origin, uuid: uuid)
				
				if let precondition = curr["precondition"].dictionary {
					branch.PreCondition.Javascript = precondition["jscode"]!.string!
				}
				
				if let condition = curr["condition"].dictionary {
					branch.Condition.Javascript = condition["jscode"]!.string!
				}
				
				if let trueTransfer = curr["ttransfer"].dictionary {
					let transferDestination = trueTransfer["destination"]!.string!
					if !transferDestination.isEmpty {
						if let destination = storyManager.find(uuid: transferDestination) {
							branch.setTrueDestination(dest: destination)
						} else {
							NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(trueTransfer["destination"]!.string!)) when setting a Branch's true Transfer's destination (\(uuid.uuidString)).", level: .warning)
						}
					}
					
					if let function = trueTransfer["function"]?.dictionary {
						branch.TrueTransfer.Function.Javascript = function["jscode"]!.string!
					}
				}
				
				if let falseTransfer = curr["ftransfer"].dictionary {
					let transferDestination = falseTransfer["destination"]!.string!
					if !transferDestination.isEmpty {
						if let destination = storyManager.find(uuid: transferDestination) {
							branch.setFalseDestination(dest: destination)
						} else {
							NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(falseTransfer["destination"]!.string!)) when setting a Branch's false Transfer's destination (\(uuid.uuidString)).", level: .warning)
						}
					}
					
					if let function = falseTransfer["function"]?.dictionary {
						branch.FalseTransfer.Function.Javascript = function["jscode"]!.string!
					}
				}

			case "switch":
				let swtch = storyManager.makeSwitch(origin: origin, uuid: uuid)
				
				// TODO: Preconditions
//				if let precondition = curr["precondition"].dictionary {
//					branch.PreCondition.Javascript = precondition["jscode"]!.string!
//				}
				
				if let defaultTransfer = curr["dtransfer"].dictionary {
					let transferDestination = defaultTransfer["destination"]!.string!
					if !transferDestination.isEmpty {
						if let destination = storyManager.find(uuid: transferDestination) {
							swtch.DefaultTransfer.Destination = destination
						} else {
							NVLog.log("NVStoryManager::fromJSON(): Unable to find Object by UUID (\(transferDestination)) when setting a Switch's default Transfer's destination (\(uuid.uuidString)).", level: .warning)
						}
					}
					
					if let function = defaultTransfer["function"]?.dictionary {
						swtch.DefaultTransfer.Function.Javascript = function["jscode"]!.string!
					}
				}
				
			default:
				NVLog.log("NVStoryManager::fromJSON(): Encountered invalid link type (\(curr["linktype"].string!))", level: .warning)
			}
		}
		
		// 8. add links to graphs by uuid
		for curr in json["graphs"].arrayValue {
			let graph = storyManager.find(uuid: curr["uuid"].string!) as! NVGraph
			
			for child in curr["links"].arrayValue {
				if let link = storyManager.find(uuid: child.string!) as? NVBaseLink {
					graph.add(link: link)
				} else {
					NVLog.log("NVStoryManager::fromJSON(): Unable to find BaseLink by UUID (\(child.string!)) when adding to Graph (\(graph.UUID.uuidString)).", level: .warning)
				}
			}
		}
		
		// 9. assign folders and graphs to story's local stuff
		for curr in json["story"]["folders"].arrayValue {
			if let folder = storyManager.find(uuid: curr.string!) as? NVFolder {
				storyManager.Story.add(folder: folder)
			} else {
				NVLog.log("NVStoryManager::fromJSON(): Unable to find Folder by UUID (\(curr.string!)) when adding to Story.", level: .warning)
			}
			
		}
		for curr in json["story"]["graphs"].arrayValue {
			if let graph = storyManager.find(uuid: curr.string!) as? NVGraph {
				storyManager.Story.add(graph: graph)
			} else {
				NVLog.log("NVStoryManager::fromJSON(): Unable to find Graph by UUID (\(curr.string!)) when adding to Story.", level: .warning)
			}
		}
		
		// 10. read story's name
		if let storyName = json["story"]["name"].string {
			storyManager.Story.Name = storyName
		}
		
		return storyManager
	}
}

// MARK: - - Schema -
extension NVStoryManager {
	static let JSON_SCHEMA: JSONDict = [
		"$schema": "http://json-schema.org/draft-04/schema#",
		"description": "Schema for Novella Story.",
		
		// MARK: top-level
		"type": "object",
		"properties": [
			"variables": [
				"type": "array",
				"items": [ "$ref": "#/definitions/variable" ]
			],
			"entities": [
				"type": "array",
				"items": [ "$ref": "#/definitions/entity" ]
			],
			"folders": [
				"type": "array",
				"items": [ "$ref": "#/definitions/folder" ]
			],
			"graphs": [
				"type": "array",
				"items": [ "$ref": "#/definitions/graph" ]
			],
			"links": [
				"type": "array",
				"items": [ "$ref": "#/definitions/link" ]
			],
			"nodes": [
				"type": "array",
				"items": [ "$ref": "#/definitions/node" ]
			],
			"story": [
				"$ref": "#/definitions/story"
			]
		],
		"required": ["variables", "entities", "folders", "graphs", "links", "nodes", "story"],
		// END top-level
		
		// MARK: definitions
		"definitions": [
			// MARK: position
			"position": [
				"type": "object",
				"properties": [
					"x": [ "type": "number" ],
					"y": [ "type": "number" ]
				],
				"required": ["x", "y"]
			],
			// END position
			
			// MARK: name
			"name": [
				"type": "string"
			],
			// END name
			
			// MARK: uuid
			"uuid": [
				"anyOf": [
					[
						"type": "string",
						// Conforms to RFC 4122 Version 4 (https://developer.apple.com/documentation/foundation/nsuuid and https://stackoverflow.com/a/38191078)
						"pattern": "[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}"
					],
					[
						"type": "string",
						"minLength": 0,
						"maxLength": 0
					]
				]
			],
			// END uuid
			
			// MARK: value
			"value": [
				"anyOf": [
					[ "type": "integer" ],
					[ "type": "boolean" ],
					// technically handles integers, but is for floats
					[ "type": "number" ]
				]
			],
			// END value
			
			// MARK: variable
			"variable": [
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"name": [ "$ref": "#/definitions/name" ],
					// This is mapped to DataType.stringValue
					"datatype": [
						"type": "string",
						"enum": ["boolean", "integer", "double"]
					],
					"value": [ "$ref": "#/definitions/value" ],
					"initialValue": [ "$ref": "#/definitions/value" ],
					"constant": [ "type": "boolean" ],
					"synopsis": [ "type": "string" ]
				],
				"required": ["uuid", "name", "datatype"],
				// MARK: variable-dependencies
				"dependencies": [
					// validate initialValue/value type matches datatype
					"datatype": [
						"oneOf": [
							// integer
							[
								"properties": [
									"datatype": [ "enum": ["integer"] ],
									"value": [ "type": "integer" ],
									"initialValue": [ "type": "integer" ]
								]
							],
							// boolean
							[
								"properties": [
									"datatype": [ "enum": ["boolean"] ],
									"value": [ "type": "boolean" ],
									"initialValue": [ "type": "boolean" ]
								]
							],
							// double
							[
								"properties": [
									"datatype": [ "enum": ["double"] ],
									"value": [ "type": "number" ],
									"initialValue": [ "type": "number"]
								]
							]
						]
					]
				]
				// END variable-dependencies
			],
			// END variable
			
			// MARK: entity
			"entity": [
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"name": [ "$ref": "#/definitions/name" ],
					"image": [ "type": "string" ]
				],
				"required": ["uuid", "name"]
			],
			// END entity
			
			// MARK: folder
			"folder": [
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"name": [ "$ref": "#/definitions/name" ],
					"subfolders": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"variables": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					]
				],
				"required": ["uuid", "name"]
			],
			// END folder
			
			// MARK: graph
			"graph": [
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"name": [ "$ref": "#/definitions/name" ],
					"position": [ "$ref": "#/definitions/position" ],
					"entry": [ "$ref": "#/definitions/uuid" ],
					"subgraphs": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"nodes": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"links": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"listeners": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					]
				],
				"required": ["uuid", "name", "position"]
			],
			// END graph
			
			// MARK: link
			"link": [
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					// One for each concrete Link.
					"linktype": [
						"type": "string",
						"enum": ["link", "branch", "switch"]
					],
					"origin": [ "$ref": "#/definitions/uuid" ]
				],
				"required": ["uuid", "linktype", "origin"],
				// MARK: link-dependencies
				"dependencies": [
					// handle each concrete link's schema based on linktype
					"linktype": [
						"oneOf": [
							// link
							[
								"properties": [
									"linktype": [ "enum": ["link"] ],
									"precondition": [ "$ref": "#/definitions/condition" ],
									"transfer": [ "$ref": "#/definitions/transfer" ]
								]
							],
							// branch
							[
								"properties": [
									"linktype": [ "enum": ["branch"] ],
									"precondition": [ "$ref": "#/definitions/condition" ],
									"condition": [ "$ref": "#/definitions/condition" ],
									"ttransfer": [ "$ref": "#/definitions/transfer" ],
									"ftransfer": [ "$ref": "#/definitions/transfer" ]
								]
							],
							
							// switch
							[
								"properties": [
									"linktype": [ "enum": ["switch"] ],
									"precondition": [ "$ref": "#/definitions/condition" ],
									"dtransfer": [ "$ref": "#/definitions/transfer" ]
									// TODO: Complete switch's properties.
								]
							]
						]
					]
				]
				// END link-dependencies
			],
			// END link
			
			// MARK: function
			"function": [
				"type": "object",
				"properties": [
					"jscode": [ "type": "string" ]
				],
				"required": ["jscode"]
			],
			// END function
			
			// MARK: transfer
			"transfer": [
				"type": "object",
				"properties": [
					"destination": [ "$ref": "#/definitions/uuid" ],
					"function": [ "$ref": "#/definitions/function" ]
				],
				"required": ["destination"]
			],
			// END transfer
			
			// MARK: condition
			"condition": [
				"type": "object",
				"properties": [
					"jscode": [ "type": "string" ]
				],
				"required": ["jscode"]
			],
			// END condition
			
			// MARK: node
			"node": [
				"type": "object",
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					// one for each concrete type
					"nodetype": [
						"type": "string",
						"enum": ["dialog", "delivery", "cutscene", "context"]
					],
					"position": [ "$ref": "#/definitions/position" ],
					"name": [ "$ref": "#/definitions/name" ]
				],
				"required": ["uuid", "nodetype", "position"],
				// MARK: node-dependencies
				"dependencies": [
					// handle each node type based on the nodetype
					"nodetype": [
						"oneOf": [
							// dialog
							[
								"properties": [
									"nodetype": [ "enum": ["dialog"] ],
									"speaker": [ "$ref": "#/definitions/uuid" ],
									"content": [ "type": "string" ],
									"preview": [ "type": "string" ],
									"directions": [ "type": "string" ]
								],
								"required": []
							],
							// delivery
							[
								"properties": [
									"nodetype": [ "enum": ["delivery"] ],
									"content": [ "type": "string" ],
									"preview": [ "type": "string" ],
									"directions": [ "type": "string" ]
								],
								"required": []
							],
							// cutscene
							[
								"properties": [
									"nodetype": [ "enum": ["cutscene"] ]
									// TODO: cutscene properties
								],
								"required": []
							],
							// context
							[
								"properties": [
									"nodetype": [ "enum": ["context"] ]
									// TODO: context properties
								],
								"required": []
							]
						]
					]
				]
				// END node-dependencies
			],
			// END node
			
			// MARK: story
			"story": [
				"type": "object",
				"properties": [
					"folders": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"graphs": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"name": [ "$ref": "#/definitions/name" ]
				],
				"required": ["folders", "graphs"]
			]
			// END story
		]
		// END definitions
	]
}
