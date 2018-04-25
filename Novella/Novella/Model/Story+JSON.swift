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
			]
		],
		"required": ["variables", "folders", "graphs", "links"],
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
					]
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
				"type": "object"
			]
			// END transfer
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
			
			if curr is Link {
				entry["linktype"] = "link"
				// TODO: Condition.
				let transfer: JSONDict = [:]
				entry["transfer"] = transfer
				// TODO: Transfer.
				
			}
			else if curr is Branch {
				entry["linktype"] = "branch"
				// TODO: Condition.
				// TODO: True Transfer.
				let ttransfer: JSONDict = [:]
				entry["ttransfer"] = ttransfer
				// TODO: False Transfer.
				let ftransfer: JSONDict = [:]
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
		
		// read all variables
		for curr in json["variables"].arrayValue {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let synopsis = curr["synopsis"].stringValue
			let type = DataType.fromString(str: curr["datatype"].stringValue)
			let constant = curr["constant"].boolValue
			
			// value and initialValue
			let value: Any
			let initialValue: Any
			switch type {
			case .boolean:
				value = curr["value"].boolValue
				initialValue = curr["initialValue"].boolValue
			case .integer:
				value = curr["value"].intValue
				initialValue = curr["initialValue"].intValue
			case .double:
				value = curr["value"].doubleValue
				initialValue = curr["initialValue"].doubleValue
			}
			
			let v = story.makeVariable(name: name, type: type, uuid: uuid)
			v.setSynopsis(synopsis: synopsis)
			do {
				try v.setValue(val: value)
				try v.setInitialValue(val: value)
			} catch {
				print("Tried to set value and initialValue but there was a datatype mismatch.")
			}
			v.setConstant(const: constant) // remember to set initial/value before this
			print("Variable")
			print("Name: \(name)")
			print("UUID: \(uuid)")
			print("Synopsis: \(synopsis)")
			print("Type: \(type)")
			print("Constant: \(constant)")
			print("Value: \(value)")
			print("Initial: \(initialValue)")
			print()
		}
		
		// read all folders
		let folders = json["folders"].arrayValue
		for curr in folders {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let _ = story.makeFolder(name: name, uuid: uuid)
			
			print("Folder")
			print("Name: \(name)")
			print("UUID: \(uuid)")
			print()
		}
		
		// link variables to folders by uuid
		for curr in folders {
			let folder = story.findBy(uuid: curr["uuid"].stringValue) as! Folder // we know this is right
			for currVar in curr["variables"].arrayValue {
				guard let variable = story.findBy(uuid: currVar.stringValue) as? Variable else {
					throw Errors.invalid("Failed to find Folder's containing Variable by UUID.")
				}
				try! folder.add(variable: variable)
			}
		}
		
		// link folders to folders by uuid
		for curr in folders {
			let folder = story.findBy(uuid: curr["uuid"].stringValue) as! Folder // we know this is right
			for currSub in curr["subfolders"].arrayValue {
				guard let sub = story.findBy(uuid: currSub.stringValue) as? Folder else {
					throw Errors.invalid("Failed to find Folder's containing Folder by UUID.")
				}
				try! folder.add(folder: sub)
			}
		}
		
		// read all graphs
		let graphs = json["graphs"].arrayValue
		for curr in graphs {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let _ = story.makeGraph(name: name, uuid: uuid)
			
			print("Graph")
			print("Name: \(name)")
			print("UUID: \(uuid)")
			print()
		}
		
		// read all links
		let links = json["links"].arrayValue
		for curr in links {
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let linktype = curr["linktype"].stringValue
			
			print("Link")
			print("UUID: \(uuid)")
			print("Type: \(linktype)")
			print()
		}
		
		return story
	}
}
