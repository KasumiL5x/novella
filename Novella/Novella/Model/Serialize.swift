//
//  Serialize.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Serialize {
	static func write(story: Story) throws -> NSString {
		
		let root: [String:Any] = [:]
		
		
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
