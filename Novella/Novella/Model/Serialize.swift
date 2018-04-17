//
//  Serialize.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Serialize {
	static func write() throws -> NSString {
		
		// create root object
		var root: [String:Any] = [:]
		
		// must create nested entries as separate dictionaries unlike python
		var story: [String:Any] = [:]
		// fill in the dictionary again making nested dictionaries if necessary until at leaf data
		for x in 0...4 {
			let str = String(x)
			story[str] = "hi"
		}
		// add the elements AFTER filling them fully, or they won't update
		root["story"] = story
		
		
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
