//
//  Story+JSON.swift
//  Novella
//
//  Created by Daniel Green on 19/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import JSONSchema
import SwiftyJSON

typealias JSONDict = [String:Any]

extension Story {
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
			]
		],
		"required": ["variables", "folders", "graphs", "links", "nodes"],
		// END top-level
		
		// MARK: definitions
		"definitions": [
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
					"name": [ "$ref": "#/definitions/name" ],
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"synopsis": [ "type": "string" ],
					// This is mapped to DataType.stringValue; TODO: Can I auto-map this?
					"datatype": [
						"type": "string",
						"enum": ["boolean", "integer", "double"]
					],
					"constant": [ "type": "boolean" ],
					"value": [ "$ref": "#/definitions/value" ],
					"initialValue": [ "$ref": "#/definitions/value" ]
				],
				"required": ["name", "uuid", "synopsis", "datatype", "constant", "value", "initialValue"],
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
					"name": [ "$ref": "#/definitions/name" ],
					"uuid": [ "$ref": "#/definitions/uuid" ],
					"subfolders": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					],
					"variables": [
						"type": "array",
						"items": [ "$ref": "#/definitions/uuid" ]
					]
				],
				"required": ["name", "uuid", "subfolders", "variables"]
			],
			// END folder
			
			// MARK: graph
			"graph": [
				"properties": [
					"name": [ "$ref": "#/definitions/name" ],
					"uuid": [ "$ref": "#/definitions/uuid" ],
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
				"required": ["name", "uuid", "subgraphs", "nodes", "links", "listeners", "exits"]
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
									"transfer": [ "$ref": "#/definitions/transfer" ]
								],
								"required": ["transfer"]
							],
							// branch
							[
								"properties": [
									"linktype": [ "enum": ["branch"] ],
									"ttransfer": [ "$ref": "#/definitions/transfer" ],
									"ftransfer": [ "$ref": "#/definitions/transfer" ]
								],
								"required": ["ttransfer", "ftransfer"]
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
			
			// MARK: node
			"node": [
				"type": "object",
				"properties": [
					"uuid": [ "$ref": "#/definitions/uuid" ],
					// one for each concrete type
					"nodetype": [
						"type": "string",
						"enum": ["dialog", "delivery", "cutscene", "context"]
					]
				],
				"required": ["uuid", "nodetype"],
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
								],
								"required": ["content", "preview", "directions"]
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
			]
			// END node
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
		
		// add all flowgraphs
		var graphs: [JSONDict] = []
		for curr in _allGraphs {
			var entry: JSONDict = [:]
			entry["name"] = curr._name
			entry["uuid"] = curr._uuid.uuidString
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
			
			if let asLink = curr as? Link {
				entry["linktype"] = "link"
				// TODO: Condition.
				// TODO: Transfer.
				var transfer: JSONDict = [:]
				transfer["destination"] = asLink._transfer._destination?.UUID.uuidString ?? ""
				entry["transfer"] = transfer
			}
			else if let asBranch = curr as? Branch {
				entry["linktype"] = "branch"
				// TODO: Condition.
				// TODO: True Transfer.
				var ttransfer: JSONDict = [:]
				ttransfer["destination"] = asBranch._trueTransfer._destination?.UUID.uuidString ?? ""
				entry["ttransfer"] = ttransfer
				// TODO: False Transfer.
				var ftransfer: JSONDict = [:]
				ftransfer["destination"] = asBranch._falseTransfer._destination?.UUID.uuidString ?? ""
				entry["ftransfer"] = ftransfer
			}
			else if curr is Switch {
				entry["linktype"] = "switch"
				// TODO: Variable (UUID?)
				// TODO: Default Transfer.
				// TODO: [value:Transfer].
			}
			else {
				throw Errors.invalid("Should not have a BaseLink at all.")
			}

			links.append(entry)
		}
		root["links"] = links
		
		// add all nodes
		var nodes: [JSONDict] = []
		for curr in _allNodes {
			var entry: JSONDict = [:]
			entry["uuid"] = curr._uuid.uuidString
			
			if let asDialog = curr as? Dialog {
				entry["nodetype"] = "dialog"
				
				// TODO: Missing out the below (so it doesn't validate oneOf) doesn't print the path in the jsonschema, why?
				entry["content"] = asDialog._content
				entry["preview"] = asDialog._preview
				entry["directions"] = asDialog._directions
			}
			
			nodes.append(entry)
		}
		root["nodes"] = nodes
		
		// check if the root object is valid JSON
		if !JSONSerialization.isValidJSONObject(root) {
			throw Errors.invalid("Root object cannot form valid JSON.")
		}
		
		// test against schema
		let schema = Schema(Story.JSON_SCHEMA)
		let validated = schema.validate(root)
		if !validated.valid {
			print("Failed to validate JSON against Schema.")
			validated.errors?.forEach({print($0)})
			throw Errors.invalid("JSON did not validate against schema.")
		}
		
		// get a JSON string
		let json = JSON(root)
		guard let str = json.rawString(.utf8, options: .prettyPrinted) else {
			throw Errors.invalid("Failed to serialize into JSON data.")
		}
		return str
	}
	
	static func fromJSON(str: String) throws -> Story {
		// TODO: Should I handle name clashes of UUID internally just in case another UUID is copypasted by a user?
		
		// get Data from string
		guard let data = str.data(using: .utf8)  else {
			throw Errors.invalid("Failed to get Data from JSON string.")
		}
		
		// parse using SwiftyJSON
		let json: JSON
		do {
			json = try JSON(data: data)
		} catch {
			throw Errors.invalid("Failed to parse JSON.")
		}
		
		// test against schema
		let schema = Schema(Story.JSON_SCHEMA)
		let validated = schema.validate(json.object) // json.object is the root object
		if !validated.valid {
			print("Failed to validate JSON against Schema.")
			validated.errors?.forEach({print($0)})
			throw Errors.invalid("JSON did not validate against schema.")
		}
		
		let story = Story()
		
		// 1. read all variables
		for curr in json["variables"].arrayValue {
			let name = curr["name"].stringValue
			let dataType = DataType.fromString(str: curr["datatype"].stringValue)
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let variable = story.makeVariable(name: name, type: dataType, uuid: uuid)
			variable.setSynopsis(synopsis: curr["synopsis"].stringValue)
			variable.setConstant(const: curr["constant"].boolValue)
			switch variable._type {
			case .boolean:
				try! variable.setValue(val: curr["value"].boolValue)
				try! variable.setInitialValue(val: curr["value"].boolValue)
				break
			case .integer:
				try! variable.setValue(val: curr["value"].intValue)
				try! variable.setInitialValue(val: curr["value"].intValue)
				break
			case .double:
				try! variable.setValue(val: curr["value"].doubleValue)
				try! variable.setInitialValue(val: curr["value"].doubleValue)
				break
			}
		}
		
		// 2. read all folders
		for curr in json["folders"].arrayValue {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let folder = story.makeFolder(name: name, uuid: uuid)
			folder.setSynopsis(synopsis: curr["synopsis"].stringValue)
		}
		
		// 2.1 link variables to folders by uuid
		for curr in json["folders"].arrayValue {
			let folder = story.findBy(uuid: curr["uuid"].stringValue) as! Folder
			for child in curr["variables"].arrayValue {
				guard let variable = story.findBy(uuid: child.stringValue) as? Variable else {
					throw Errors.invalid("Failed to find Variable by UUID.")
				}
				try! folder.add(variable: variable)
			}
		}
		
		// 2.2 link subfolders to folders by uuid
		for curr in json["folders"].arrayValue {
			let folder = story.findBy(uuid: curr["uuid"].stringValue) as! Folder
			for child in curr["subfolders"].arrayValue {
				guard let subfolder = story.findBy(uuid: child.stringValue) as? Folder else {
					throw Errors.invalid("Failed to find Folder by UUID.")
				}
				try! folder.add(folder: subfolder)
			}
		}
		
		// 3. read all nodes
		for curr in json["nodes"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			switch curr["nodetype"].stringValue {
			case "dialog":
				let dialog = story.makeDialog(uuid: uuid)
				dialog.setContent(content: curr["content"].stringValue)
				dialog.setPreview(preview: curr["preview"].stringValue)
				dialog.setDirections(directions: curr["directions"].stringValue)
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
				throw Errors.invalid("Invalid node type.")
			}
		}
		
		// 4. read all listeners
		// TODO: Not yet implemented.
		
		// 5. read all exits
		// TODO: Not yet implemented.
		
		// 6. read all graphs
		for curr in json["graphs"].arrayValue {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let graph = story.makeGraph(name: name, uuid: uuid)
			
			// 6.1 link all nodes by uuid
			for child in curr["nodes"].arrayValue {
				guard let node = story.findBy(uuid: child.stringValue) as? FlowNode else {
					throw Errors.invalid("Failed to find FlowNode by UUID.")
				}
				try! graph.add(node: node)
			}
			
			// 6.2 link all listeners by UUID
			// TODO: Once listeners are parsed.
			
			// 6.3 link all exits by UUID
			// TODO: Once exits are parsed.
			
			// TODO: ENTRY POINT.
		}
		
		// 7. read all links
		for curr in json["links"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let origin = curr["origin"].stringValue
			guard let originLinkable = story.findBy(uuid: origin) as? Linkable else {
				throw Errors.invalid("ailed to find Linkable by UUID.")
			}
			
			switch curr["linktype"].stringValue {
			case "link":
				let link = story.makeLink(uuid: uuid)
				link.setOrigin(origin: originLinkable)
				let transfer = curr["transfer"].dictionaryValue
				let dest = transfer["destination"]!.stringValue
				guard let destLinkable = story.findBy(uuid: dest) as? Linkable else {
					throw Errors.invalid("Failed to find Linkable by UUID.")
				}
				link._transfer.setDestination(dest: destLinkable)
				break
			case "branch":
				let branch = story.makeBranch(uuid: uuid)
				branch.setOrigin(origin: originLinkable)
				let truetransfer = curr["ttransfer"].dictionaryValue
				let falsetransfer = curr["ftransfer"].dictionaryValue
				let trueDest = truetransfer["destination"]!.stringValue
				let falseDest = falsetransfer["destination"]!.stringValue
				guard let trueLinkable = story.findBy(uuid: trueDest) as? Linkable, let falseLinkable = story.findBy(uuid: falseDest) as? Linkable else {
					throw Errors.invalid("Failed to find Linkable by UUID.")
				}
				branch._trueTransfer.setDestination(dest: trueLinkable)
				branch._falseTransfer.setDestination(dest: falseLinkable)
				break
			case "switch":
				fatalError("Not yet implemented.")
				break
			default:
				throw Errors.invalid("Invalid link type.")
			}
		}
		
		return story
	}
}
