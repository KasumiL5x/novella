//
//  Story+JSON.swift
//  Novella
//
//  Created by Daniel Green on 19/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

typealias JSONDict = [String:Any]

extension Story {
	func toJSON() -> String {
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
			entry["initialValue"] = curr._initialValue // TODO: Convert this to string somehow, as it may kill it if it's not POD.
			entry["value"] = curr._value // TODO: Convert this to string somehow, as it may kill it if it's not POD.
			variables.append(entry)
		}
		root["variables"] = variables
		
		// check json object validity
		if !JSONSerialization.isValidJSONObject(root) {
			return ""
		}
		
		do {
			let jsonDaat = try JSONSerialization.data(withJSONObject: root, options: .prettyPrinted)
			return String(data: jsonDaat, encoding: String.Encoding.utf8)!
		} catch {
			return ""
		}
	}
	
	static func fromJSON(str: String) throws -> Story {
		// get Data from string
		guard let data = str.data(using: .utf8)  else {
			throw Errors.invalid("Failed to get Data from JSON string.")
		}
		
		// convert to json object
		var root: JSONDict = [:]
		do {
			root = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
		} catch {
			throw Errors.invalid("Failed to parse JSON.")
		}
		
		let story = Story()
		
		// read all variables
		guard let variables = root["variables"] as? [JSONDict] else {
			throw Errors.invalid("Failed to find 'variables' entry.")
		}
		for curr in variables {
			guard let uuidStr = curr["uuid"] as? String else {
				throw Errors.invalid("Failed to parse variable's UUID string.")
			}
			guard let uuid = NSUUID(uuidString: uuidStr) else {
				throw Errors.invalid("Failed to create Variable NSUUID.")
			}
			guard let name = curr["name"] as? String else {
				throw Errors.invalid("Failed to read Variable name.")
			}
			guard let typeStr = curr["type"] as? String else {
				throw Errors.invalid("Failed to read Variable's type.")
			}
			let type = DataType.fromString(str: typeStr) // TODO: Make this throw rather than fatalError.
			story.makeVariable(name: name, type: type, uuid: uuid)
		}
		
		// read all folders
		guard let folders = root["folders"] as? [JSONDict] else {
			throw Errors.invalid("Failed to find 'folders' entry.")
		}
		for curr in folders {
			guard let uuidStr = curr["uuid"] as? String else {
				throw Errors.invalid("Failed to parse Folder's UUID string.")
			}
			guard let uuid = NSUUID(uuidString: uuidStr) else {
				throw Errors.invalid("Failed to create Folder's NSUUID.")
			}
			guard let name = curr["name"] as? String else {
				throw Errors.invalid("Failed to read Folder's name.")
			}
			story.makeFolder(name: name, uuid: uuid)
		}
		
		// link variables to folders by uuid
		for currFolder in folders {
			let folder = story.findBy(uuid: currFolder["uuid"] as! String) as! Folder // this is fine as we've processed it earlier
			guard let vars = currFolder["variables"] as? [String] else {
				throw Errors.invalid("Failed to read Folder's variables.")
			}
			for currVar in vars {
				guard let v = story.findBy(uuid: currVar) as? Variable else {
					throw Errors.invalid("Failed to find Folder's containing variable by UUID.")
				}
				try! folder.add(variable: v)
			}
		}
		
		// link folders to folders by uuid
		for currFolder in folders {
			let folder = story.findBy(uuid: currFolder["uuid"] as! String) as! Folder // this is fine as we've processed it earlier
			guard let subs = currFolder["subfolders"] as? [String] else {
				throw Errors.invalid("Failed to read Folder's subfolders.")
			}
			for currSub in subs {
				guard let f = story.findBy(uuid: currSub) as? Folder else {
					throw Errors.invalid("Failed to find Folder's containing folder by UUID.")
				}
				try! folder.add(folder: f)
			}
		}
		
		return story
	}
}
