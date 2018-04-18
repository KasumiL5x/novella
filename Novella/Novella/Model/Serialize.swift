//
//  Serialize.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Serialize {
	static func read(jsonStr: String) throws -> Story {
		var json: [String:Any] = [:]
		if let data = jsonStr.data(using: .utf8) {
			do {
				json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
			} catch {
				print(error.localizedDescription)
				throw Errors.invalid("Failed to parse JSON string.")
			}
		}
		
		let story = Story()
		
		// read all variables
		if let variables = json["variables"] as? [[String:Any]] {
			for x in variables {
				let uuid = NSUUID(uuidString: x["uuid"] as! String)
				let name = x["name"] as! String
				let type = DataType.fromString(str: x["type"] as! String)
				story.makeVariable(name: name, type: type, uuid: uuid)
			}
		} else {
			print("Failed to read variables.")
		}
		
		// read all folders
		if let folders = json["folders"] as? [[String:Any]] {
			for x in folders {
				let uuid = NSUUID(uuidString: x["uuid"] as! String)
				let name = x["name"] as! String
				story.makeFolder(name: name, uuid: uuid)
			}
		}
		
		// link variables to folders by uuid
		if let folders = json["folders"] as? [[String:Any]] {
			for x in folders {
				let f = try! story.findBy(uuid: NSUUID(uuidString: x["uuid"] as! String)!) as! Folder
				let vars: [String] = x["variables"] as! [String]
				for y in vars {
						let v = try! story.findBy(uuid: NSUUID(uuidString: y)!) as! Variable
						try! f.add(variable: v)
				}
			}
		}
		// link folders to folders by uuid
		if let folders = json["folders"] as? [[String:Any]] {
			for x in folders {
				let f = try! story.findBy(uuid: NSUUID(uuidString: x["uuid"] as! String)!) as! Folder
				let fols: [String] = x["subfolders"] as! [String]
				for y in fols {
					let v = try! story.findBy(uuid: NSUUID(uuidString: y)!) as! Folder
					try! f.add(folder: v)
				}
			}
		}

		
		// Always read all data first, THEN link everything.
		// For instance, read all varibles and folders, THEN set up the parenting via UUID lookup.
		
		print(json)
		
		return story
	}
	
	static func write(story: Story) throws -> NSString {
		
		// create root object
		var root: [String:Any] = [:]
		
		// all Folders
		var allFolders: [[String:Any]] = []
		for currFolder in story._allFolders {
			var entry: [String:Any] = [:]
			entry["name"] = currFolder.Name
			entry["uuid"] = currFolder.UUID.uuidString
			entry["variables"] = currFolder.Variables.map({$0.UUID.uuidString})
			entry["subfolders"] = currFolder.Folders.map({$0.UUID.uuidString})
			allFolders.append(entry)
		}
		root["folders"] = allFolders
		
		// all Variables
		var allVariables: [[String: Any]] = []
		for currVar in story._allVariables {
			var entry: [String:Any] = [:]
			entry["name"] = currVar.Name
			entry["uuid"] = currVar.UUID.uuidString
			entry["synopsis"] = currVar.Synopsis
			entry["type"] = currVar.DataType.stringValue
			entry["constant"] = currVar.IsConstant
			entry["initialValue"] = currVar.InitialValue // TODO: Convert this to string somehow, as it may kill it if it's not POD.
			entry["value"] = currVar.Value // TODO: Convert this to string somehow, as it may kill it if it's not POD.
			allVariables.append(entry)
		}
		root["variables"] = allVariables
		
		if !JSONSerialization.isValidJSONObject(root) {
			throw Errors.invalid("JSON object is not valid.")
		}
		
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: root, options: .prettyPrinted)
			return NSString(data: jsonData, encoding: 1)!
		} catch _ {
			throw Errors.invalid("Failed to convert JSON object.")
		}
	}
}
