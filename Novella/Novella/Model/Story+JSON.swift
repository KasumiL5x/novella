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
}
