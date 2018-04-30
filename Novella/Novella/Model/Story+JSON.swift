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
			],
			"story": [
				"$ref": "#/definitions/story"
			]
		],
		"required": ["variables", "folders", "graphs", "links", "nodes", "story"],
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
				"required": ["name", "uuid"]
			],
			// END folder
			
			// MARK: graph
			"graph": [
				"properties": [
					"name": [ "$ref": "#/definitions/name" ],
					"uuid": [ "$ref": "#/definitions/uuid" ],
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
				"required": ["name", "uuid", "entry", "subgraphs", "nodes", "links", "listeners", "exits"]
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
					]
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
		
		// add all flowgraphs
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
		
		// add folders and graphs (uuid) for story
		var storyEntry: JSONDict = [:]
		storyEntry["folders"] = _folders.map({$0._uuid.uuidString})
		storyEntry["graphs"] = _graphs.map({$0._uuid.uuidString})
		root["story"] = storyEntry
		
		
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
	
	static func fromJSON(str: String) throws -> (story: Story, errors: [String]) {
		var errors: [String] = []
		
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
			let dataType = DataType.fromString(str: curr["datatype"].string!)
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
				if let variable = story.findBy(uuid: child.string!) as? Variable {
					try! folder.add(variable: variable)
				} else {
					errors.append("Unable to find Variable by UUID (\(child.string!) when adding to Folder (\(uuid.uuidString)).")
				}
			}
		}
		
		// 2.2 link subfolders to folders by uuid
		for curr in json["folders"].arrayValue {
			let folder = story.findBy(uuid: curr["uuid"].string!) as! Folder
			for child in curr["subfolders"].arrayValue {
				if let subfolder = story.findBy(uuid: child.string!) as? Folder {
					try! folder.add(folder: subfolder)
				} else {
					errors.append("Unable to find Folder by UUID (\(child.string!)) when adding to Folder (\(curr["uuid"].string!)).")
				}
				
			}
		}
		
		// 3. read all nodes
		for curr in json["nodes"].arrayValue {
			let uuid = NSUUID(uuidString: curr["uuid"].string!)!
			switch curr["nodetype"].string! {
			case "dialog":
				let dialog = story.makeDialog(uuid: uuid)
				
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
			
			// 6.2 link entry by uuid
			guard let entryLinkable = story.findBy(uuid: curr["entry"].stringValue) as? Linkable else {
				throw Errors.invalid("Failed to find Linkable by UUID.")
			}
			try! graph.setEntry(entry: entryLinkable)
			
			// 6.3 link all listeners by UUID
			// TODO: Once listeners are parsed.
			
			// 6.4 link all exits by UUID
			// TODO: Once exits are parsed.
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
		
		// 8. add links to graphs by uuid
		for curr in json["graphs"].arrayValue {
			let graph = story.findBy(uuid: curr["uuid"].stringValue) as! FlowGraph
			
			for child in curr["links"].arrayValue {
				guard let link = story.findBy(uuid: child.stringValue) as? BaseLink else {
					throw Errors.invalid("Failed to find BaseLink by UUID.")
				}
				try! graph.add(link: link)
			}
		}
		
		// 9. assign folders and graphs to story's local stuff
		for curr in json["story"]["folders"].arrayValue {
			guard let folder = story.findBy(uuid: curr.stringValue) as? Folder else {
				throw Errors.invalid("Failed to find Folder by UUID.")
			}
			try! story.add(folder: folder)
		}
		for curr in json["story"]["graphs"].arrayValue {
			guard let graph = story.findBy(uuid: curr.stringValue) as? FlowGraph else {
				throw Errors.invalid("Failed to find FlowGraph by UUID.")
			}
			try! story.add(graph: graph)
		}
		
		// ERROR1: Investigate making almost everything except core properties optional and handling in code
		// ERROR1: Remove throws (except for fatal errors) and instead build a list of string errors and print/return them all at the end
		
		return (story, errors)
	}
}
