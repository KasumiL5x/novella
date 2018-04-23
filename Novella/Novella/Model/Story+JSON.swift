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
		"description": "Schema for Novella Story.",
		"type": "object",
		"properties": [
			"variables": [
				"type": "array",
				"items": ["$ref": "#/definitions/variable"]
			],
			"folders": [
				"type": "array",
				"items": ["$ref": "#/definitions/folder"]
			]
		],
		"required": ["variables", "folders"],
		
		// DEFINITIONS
		"definitions": [
			// uuid
			"uuid": [
				"type": "string",
				"pattern": "[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}" // Conforms to RFC 4122 Version 4 (https://developer.apple.com/documentation/foundation/nsuuid and https://stackoverflow.com/a/38191078)
			],
			// value
			"value": [
				"anyOf": [
					["type": "number"],
					["type": "boolean"],
					["type": "string"]
				]
			],
			// variable
			"variable": [
				"properties": [
					"name": ["type": "string"],
					"uuid": ["$ref": "#/definitions/uuid"],
					"synopsis": ["type": "string"],
					"type": ["type": "string"], // TODO: Make it an enum of allowed types (defined in DataType string function).
					"constant": ["type": "boolean"],
					"value": ["$ref": "#/definitions/value"],
					"initialValue": ["$ref": "#/definitions/value"],
				],
				"required": ["name", "uuid", "synopsis", "type", "constant", "value", "initialValue"]
			],
			// folder
			"folder": [
				"properties": [
					"name": ["type": "string"],
					"uuid": ["$ref": "#/definitions/uuid"],
					"subfolders": [
						"type": "array",
						"items": ["$ref": "#/definitions/uuid"],
					],
					"variables": [
						"type": "array",
						"items": ["$ref": "#/definitions/uuid"],
					]
				],
				"required": ["name", "uuid", "subfolders", "variables"]
			]
		]
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
			entry["type"] = curr._type.stringValue
			entry["constant"] = curr._constant
			entry["initialValue"] = curr._initialValue
			entry["value"] = curr._value
			variables.append(entry)
		}
		root["variables"] = variables
		
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
			let type = DataType.fromString(str: curr["type"].stringValue)
			let constant = curr["constant"].boolValue
			// TODO: Figure out how to handle initial/Value. Probably just need to switch case and let based on its type? Technically user could change it. May need to validate matching types. Possibly do this in schema with the conditionals?
			let v = story.makeVariable(name: name, type: type, uuid: uuid)
			v.setSynopsis(synopsis: synopsis)
			v.setConstant(const: constant) // remember to set initial/value before this
//			print("Name: \(name)")
//			print("UUID: \(uuid)")
//			print("Synopsis: \(synopsis)")
//			print("Type: \(type)")
//			print("Constant: \(constant)")
//			print()
		}
		
		// read all folders
		let folders = json["folders"].arrayValue
		for curr in folders {
			let name = curr["name"].stringValue
			let uuid = NSUUID(uuidString: curr["uuid"].stringValue)!
			let _ = story.makeFolder(name: name, uuid: uuid)
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
		
		
		
		
		
		return story
	}
}
