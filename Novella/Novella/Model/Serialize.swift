//
//  Serialize.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Serialize {
	static func write(engine: Engine) throws -> NSString {
		
		// create root object
		var root: [String:Any] = [:]
		
		// all Folders
		var allFolders: [[String:Any]] = []
		for currFolder in engine._folders {
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
		for currVar in engine._variables {
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
