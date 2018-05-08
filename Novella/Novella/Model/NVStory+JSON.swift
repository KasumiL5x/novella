//
//  NVStory+JSON.swift
//  Novella
//
//  Created by Daniel Green on 19/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import JSONSchema
import SwiftyJSON

typealias JSONDict = [String:Any]

extension NVStory {
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
		"required": ["variables", "folders", "graphs", "links", "nodes", "story"],
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
				"type": "string",
				// Conforms to RFC 4122 Version 4 (https://developer.apple.com/documentation/foundation/nsuuid and https://stackoverflow.com/a/38191078)
				"pattern": "[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}"
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
					// This is mapped to DataType.stringValue; TODO: Can I auto-map this?
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
					],
					"exits": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					]
				],
				"required": ["uuid", "name"]
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
				"required": ["uuid", "linktype"],
				// MARK: link-dependencies
				"dependencies": [
					// handle each concrete link's schema based on linktype
					"linktype": [
						"oneOf": [
							// link
							[
								"properties": [
									"linktype": [ "enum": ["link"] ],
									"condition": [ "$ref": "#/definitions/condition" ],
									"transfer": [ "$ref": "#/definitions/transfer" ]
								]
							],
							// branch
							[
								"properties": [
									"linktype": [ "enum": ["branch"] ],
									"condition": [ "$ref": "#/definitions/condition" ],
									"ttransfer": [ "$ref": "#/definitions/transfer" ],
									"ftransfer": [ "$ref": "#/definitions/transfer" ]
								]
							]
						]
					]
				]
				// END link-dependencies
			],
			// END link
			
			// MARK: transfer
			"transfer": [
				"type": "object",
				"properties": [
					"destination": [ "$ref": "#/definitions/uuid" ]
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
									"content": [ "type": "string" ],
									"preview": [ "type": "string" ],
									"directions": [ "type": "string" ]
									// TODO: dialog properties
								]
							],
							// delivery
							[
								"properties": [
									"nodetype": [ "enum": ["delivery"] ]
									// TODO: delivery properties
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


	
	func toJSON() throws -> String {
		var root: JSONDict = [:]
		
		// add all folders
		var folders: [JSONDict] = []
		for curr in _allFolders {
			var entry: JSONDict = [:]
			entry["name"] = curr._name
			entry["uuid"] = curr._uuid.uuidString
			entry["variables"] = curr._variables.map({$0._uuid.uuidString})
			entry["subfolders"] = curr._folders.map({$0._uuid.uuidString})
			folders.append(entry)
		}
		root["folders"] = folders
		
		// add all variables
		var variables: [JSONDict] = []
		for curr in _allVariables {
			var entry: JSONDict = [:]
			entry["name"] = curr._name
			entry["uuid"] = curr._uuid.uuidString
			entry["synopsis"] = curr._synopsis
			entry["datatype"] = curr._type.stringValue
			entry["constant"] = curr._constant
			entry["initialValue"] = curr._initialValue
			entry["value"] = curr._value
			variables.append(entry)
		}
		root["variables"] = variables
		
		// add all graphs
		var graphs: [JSONDict] = []
		for curr in _allGraphs {
			var entry: JSONDict = [:]
			entry["name"] = curr._name
			entry["uuid"] = curr._uuid.uuidString
			entry["entry"] = curr._entry?.UUID.uuidString ?? ""
			entry["subgraphs"] = curr._graphs.map({$0._uuid.uuidString})
			entry["nodes"] = curr._nodes.map({$0._uuid.uuidString})
			entry["links"] = curr._links.map({$0._uuid.uuidString})
			entry["listeners"] = curr._listeners.map({$0._uuid.uuidString})
			entry["exits"] = curr._exits.map({$0._uuid.uuidString})
			graphs.append(entry)
		}
		root["graphs"] = graphs
		
		// add all links
		var links: [JSONDict] = []
		for curr in _allLinks {
			var entry: JSONDict = [:]
			entry["uuid"] = curr._uuid.uuidString
			entry["origin"] = curr._origin?.UUID.uuidString ?? ""
			
			if let asLink = curr as? NVLink {
				entry["linktype"] = "link"
				
				var condition: JSONDict = [:]
				condition["jscode"] = asLink._condition._javascript
				entry["condition"] = condition
				
				var transfer: JSONDict = [:]
				transfer["destination"] = asLink._transfer._destination?.UUID.uuidString ?? ""
				entry["transfer"] = transfer
			}
			else if let asBranch = curr as? NVBranch {
				entry["linktype"] = "branch"
				
				var condition: JSONDict = [:]
				condition["jscode"] = asBranch._condition._javascript
				entry["condition"] = condition
				
				var ttransfer: JSONDict = [:]
				ttransfer["destination"] = asBranch._trueTransfer._destination?.UUID.uuidString ?? ""
				entry["ttransfer"] = ttransfer
				
				var ftransfer: JSONDict = [:]
				ftransfer["destination"] = asBranch._falseTransfer._destination?.UUID.uuidString ?? ""
				entry["ftransfer"] = ftransfer
			}
			else if curr is NVSwitch {
				entry["linktype"] = "switch"
				fatalError("Haven't implemented switch yet.")
				// TODO: Variable (UUID?)
				// TODO: Default Transfer.
				// TODO: [value:Transfer].
			}
			else {
				fatalError("Should never encounter a BaseLink.")
			}

			links.append(entry)
		}
		root["links"] = links
		
		// add all nodes
		var nodes: [JSONDict] = []
		for curr in _allNodes {
			var entry: JSONDict = [:]
			entry["uuid"] = curr._uuid.uuidString
			entry["name"] = curr._name
			
			entry["position"] = [
				"x": curr._editorPos.x,
				"y": curr._editorPos.y
			]
			
			if let asDialog = curr as? NVDialog {
				entry["nodetype"] = "dialog"
				
				// TODO: Missing out the below (so it doesn't validate oneOf) doesn't print the path in the jsonschema, why?
				entry["content"] = asDialog._content
				entry["preview"] = asDialog._preview
				entry["directions"] = asDialog._directions
			}
			
			nodes.append(entry)
		}
		root["nodes"] = nodes
		
		// add folders and graphs (uuid) for story
		var storyEntry: JSONDict = [:]
		storyEntry["folders"] = _folders.map({$0._uuid.uuidString})
		storyEntry["graphs"] = _graphs.map({$0._uuid.uuidString})
		storyEntry["name"] = _name
		root["story"] = storyEntry
		
		
		// check if the root object is valid JSON
		if !JSONSerialization.isValidJSONObject(root) {
			throw NVError.invalid("Root object cannot form valid JSON.")
		}
		
		// test against schema
		let schema = Schema(NVStory.JSON_SCHEMA)
		let validated = schema.validate(root)
		if !validated.valid {
			print("Failed to validate JSON against Schema.")
			validated.errors?.forEach({print($0)})
			throw NVError.invalid("JSON did not validate against schema.")
		}
		
		// get a JSON string
		let json = JSON(root)
		guard let str = json.rawString(.utf8, options: .prettyPrinted) else {
			throw NVError.invalid("Failed to serialize into JSON data.")
		}
		return str
	}
	
	static func fromJSON(str: String) throws -> (story: NVStory, errors: [String]) {
		var errors: [String] = []
		
		// TODO: Should I handle name clashes of UUID internally just in case another UUID is copypasted by a user?
		
		// get Data from string
		guard let data = str.data(using: .utf8)  else {
			throw NVError.invalid("Failed to get Data from JSON string.")
		}
		
		// parse using SwiftyJSON
		let json: JSON
		do {
			json = try JSON(data: data)
		} catch {
			throw NVError.invalid("Failed to parse JSON.")
		}
		
		// test against schema
		let schema = Schema(NVStory.JSON_SCHEMA)
		let validated = schema.validate(json.object) // json.object is the root object
		if !validated.valid {
			print("Failed to validate JSON against Schema.")
			validated.errors?.forEach({print($0)})
			throw NVError.invalid("JSON did not validate against schema.")
		}
		
		let story = NVStory()
		
		// 1. read all variables
		for curr in json["variables"].arrayValue {
			let dataType = NVDataType.fromString(str: curr["datatype"].string!)
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			let variable = story.makeVariable(name: curr["name"].string!, type: dataType, uuid: uuid)
			
			if let synopsis = curr["synopsis"].string {
				variable.setSynopsis(synopsis: synopsis)
			}
			
			if let constant = curr["constant"].bool {
				variable.setConstant(const: constant)
			}
			
			let value = curr["value"]
			let initialValue = curr["initialValue"]
			switch variable._type {
			case .boolean:
				if value != JSON.null {
					try! variable.setValue(val: value.bool!)
				}
				if initialValue != JSON.null {
					try! variable.setInitialValue(val: initialValue.bool!)
				}
				break
			case .integer:
				if value != JSON.null {
					try! variable.setValue(val: value.int!)
				}
				if initialValue != JSON.null {
					try! variable.setInitialValue(val: initialValue.int!)
				}
				break
			case .double:
				if value != JSON.null {
					try! variable.setValue(val: value.double!)
				}
				if initialValue != JSON.null {
					try! variable.setInitialValue(val: initialValue.double!)
				}
				break
			}
		}
		
		// 2. read all folders
		for curr in json["folders"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			let folder = story.makeFolder(name: curr["name"].string!, uuid: uuid)
			
			if let synopsis = curr["synopsis"].string {
				folder.setSynopsis(synopsis: synopsis)
			}
			
			// 2.1 link variables to folders by uuid
			for child in curr["variables"].arrayValue {
				if let variable = story.findBy(uuid: child.string!) as? NVVariable {
					try! folder.add(variable: variable)
				} else {
					errors.append("Unable to find Variable by UUID (\(child.string!) when adding to Folder (\(uuid.uuidString)).")
				}
			}
		}
		
		// 2.2 link subfolders to folders by uuid
		for curr in json["folders"].arrayValue {
			let folder = story.findBy(uuid: curr["uuid"].string!) as! NVFolder
			for child in curr["subfolders"].arrayValue {
				if let subfolder = story.findBy(uuid: child.string!) as? NVFolder {
					try! folder.add(folder: subfolder)
				} else {
					errors.append("Unable to find Folder by UUID (\(child.string!)) when adding to Folder (\(curr["uuid"].string!)).")
				}
				
			}
		}
		
		// 3. read all nodes
		for curr in json["nodes"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			
			let name = curr["name"].string
			
			let posX = curr["position"]["x"].int!
			let posY = curr["position"]["y"].int!
			
			switch curr["nodetype"].string! {
			case "dialog":
				let dialog = story.makeDialog(uuid: uuid)
				dialog._editorPos = NSPoint(x: posX, y: posY)
				
				if name != nil {
					dialog.Name = name!
				}
				
				if let content = curr["content"].string {
					dialog.setContent(content: content)
				}
				
				if let preview = curr["preview"].string {
					dialog.setPreview(preview: preview)
				}
				
				if let directions = curr["directions"].string {
					dialog.setDirections(directions: directions)
				}
				break
			case "delivery":
				fatalError("Not yet implemented.")
				break
			case "cutscene":
				fatalError("Not yet implemented.")
				break
			case "context":
				fatalError("Not yet implemented.")
				break
			default:
				fatalError("Invalid node type.")
			}
		}
		
		// 4. read all listeners
		// TODO: Not yet implemented.
		
		// 5. read all exits
		// TODO: Not yet implemented.
		
		// 6. read all graphs
		for curr in json["graphs"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let graph = story.makeGraph(name: curr["name"].string!, uuid: uuid)
			
			// 6.1 link all nodes by uuid
			for child in curr["nodes"].arrayValue {
				if let node = story.findBy(uuid: child.string!) as? NVNode {
					try! graph.add(node: node)
				} else {
					errors.append("Unable to find Node by UUID (\(child.string!) when adding to Graph (\(uuid.uuidString)).")
				}
			}
			
			// 6.2 link all listeners by UUID
			// TODO: Once listeners are parsed.
			
			// 6.3 link all exits by UUID
			// TODO: Once exits are parsed.
		}
		
		// 6.4 link all subgraphs by uuid
		for curr in json["graphs"].arrayValue {
			let graph = story.findBy(uuid: curr["uuid"].string!) as! NVGraph
			for child in curr["subgraphs"].arrayValue {
				if let subgraph = story.findBy(uuid: child.string!) as? NVGraph {
					try! graph.add(graph: subgraph)
				} else {
					errors.append("Unable to find Graph by UUID (\(child.string!)) when adding to Graph (\(curr["uuid"].string!)).")
				}
			}
		}
		
		// 6.5 link all entry points by uuid (done after as an entry could be a subgraph)
		for curr in json["graphs"].arrayValue {
			let graph = story.findBy(uuid: curr["uuid"].string!) as! NVGraph
			if let entry = curr["entry"].string {
				if let linkable = story.findBy(uuid: entry) as? NVLinkable {
					try! graph.setEntry(entry: linkable)
				} else {
					errors.append("Unable to find Linkable by UUID (\(entry)) when setting Graph's entry (\(graph._uuid.uuidString)).")
				}
			}
		}
		
		// 7. read all links
		for curr in json["links"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			
			var origin: NVLinkable? = nil
			if let originID = curr["origin"].string {
				origin = story.findBy(uuid: originID) as? NVLinkable
				if origin == nil {
					errors.append("Unable to find Linkable by UUID (\(originID)) when setting the origin of a BaseLink (\(uuid.uuidString)).")
				}
			}
			
			switch curr["linktype"].string! {
			case "link":
				let link = story.makeLink(uuid: uuid)
				
				link.setOrigin(origin: origin)
				
				if let condition = curr["condition"].dictionary {
					link._condition._javascript = condition["jscode"]!.string!
				}
				
				if let transfer = curr["transfer"].dictionary {
					if let destination = story.findBy(uuid: transfer["destination"]!.string!) as? NVLinkable {
						link._transfer.setDestination(dest: destination)
					} else {
						errors.append("Unable to find Linkable by UUID (\(transfer["destination"]!.string!)) when setting a Link's Transfer's destination (\(uuid.uuidString)).")
					}
				}
				break
			case "branch":
				let branch = story.makeBranch(uuid: uuid)
				
				branch.setOrigin(origin: origin)
				
				if let condition = curr["condition"].dictionary {
					branch._condition._javascript = condition["jscode"]!.string!
				}
				
				if let trueTransfer = curr["ttransfer"].dictionary {
					if let destination = story.findBy(uuid: trueTransfer["destination"]!.string!) as? NVLinkable {
						branch._trueTransfer.setDestination(dest: destination)
					} else {
						errors.append("Unable to find Linkable by UUID (\(trueTransfer["destination"]!.string!)) when setting a Branch's true Transfer's destination (\(uuid.uuidString)).")
					}
				}
				
				if let falseTransfer = curr["ftransfer"].dictionary {
					if let destination = story.findBy(uuid: falseTransfer["destination"]!.string!) as? NVLinkable {
						branch._falseTransfer.setDestination(dest: destination)
					} else {
						errors.append("Unable to find Linkable by UUID (\(falseTransfer["destination"]!.string!)) when setting a Branch's false Transfer's destination (\(uuid.uuidString)).")
					}
				}
				break
			case "switch":
				fatalError("Not yet implemented.")
				break
			default:
				fatalError("Invalid link type.")
			}
		}
		
		// 8. add links to graphs by uuid
		for curr in json["graphs"].arrayValue {
			let graph = story.findBy(uuid: curr["uuid"].string!) as! NVGraph
			
			for child in curr["links"].arrayValue {
				if let link = story.findBy(uuid: child.string!) as? NVBaseLink {
					try! graph.add(link: link)
				} else {
					errors.append("Unable to find BaseLink by UUID (\(child.string!)) when adding to Graph (\(graph._uuid.uuidString)).")
				}
			}
		}
		
		// 9. assign folders and graphs to story's local stuff
		for curr in json["story"]["folders"].arrayValue {
			if let folder = story.findBy(uuid: curr.string!) as? NVFolder {
				try! story.add(folder: folder)
			} else {
				errors.append("Unable to find Folder by UUID (\(curr.string!)) when adding to Story.")
			}
			
		}
		for curr in json["story"]["graphs"].arrayValue {
			if let graph = story.findBy(uuid: curr.string!) as? NVGraph {
				try! story.add(graph: graph)
			} else {
				errors.append("Unable to find Graph by UUID (\(curr.string!)) when adding to Story.")
			}
		}
		
		// 10. read story's name
		if let storyName = json["story"]["name"].string {
			story._name = storyName
		}
		
		return (story, errors)
	}
}
