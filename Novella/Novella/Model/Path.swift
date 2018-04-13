//
//  Path.swift
//  Novella
//
//  Created by Daniel Green on 13/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

protocol Pathable {
	// the name/id of the current path
	func localPath() -> String
	
	// the parenting path to the current path; nil indicates no parent
	func parentPath() -> Pathable?
}

class Path {
	static let DELIMITER = "."
	
	static func fullPathTo(object: Pathable) -> String {
		var str = ""
		
		// add parent paths with delimiter
		var currParent = object.parentPath()
		while currParent != nil {
			str += currParent!.localPath() + Path.DELIMITER
			currParent = currParent!.parentPath()
		}
		
		// add local path
		str += object.localPath()
		
		return str
	}
}
