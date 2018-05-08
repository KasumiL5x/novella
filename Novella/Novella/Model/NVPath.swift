//
//  NVPath.swift
//  Novella
//
//  Created by Daniel Green on 13/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

protocol NVPathable {
	// the name/id of the current path
	func localPath() -> String
	
	// the parenting path to the current path; nil indicates no parent
	func parentPath() -> NVPathable?
}

class NVPath {
	static let DELIMITER = "."
	
	static func fullPathTo(_ pathable: NVPathable) -> String {
		var str = ""
		
		// add parent paths with delimiter
		var currParent = pathable.parentPath()
		while currParent != nil {
			str = (currParent!.localPath() + NVPath.DELIMITER) + str // add reverse order b/c we're going bottom up
			currParent = currParent!.parentPath()
		}
		
		// add local path
		str += pathable.localPath()
		
		return str
	}
}
