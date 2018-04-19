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
		
		// ERROR: Fill this in and maybe throw instead of empty string.
		
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
