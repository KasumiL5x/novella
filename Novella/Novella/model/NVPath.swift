//
//  NVPath.swift
//  novella
//
//  Created by dgreen on 07/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

typealias NVPathResult = (path: String, objects: [Any])

protocol NVPathable {
	func localPath() -> String
	func localObject() -> Any
	func parentPathable() -> NVPathable?
}

class NVPath {
	static let DELIM = "/"
	
	static func fullPath(_ pathable: NVPathable) -> NVPathResult {
		var str = ""
		var obj: [Any] = []
		
		// add parent paths with delimiter
		var currParent = pathable.parentPathable()
		while currParent != nil {
			str = (currParent!.localPath() + NVPath.DELIM) + str // add reverse order b/c we're going bottom up
			obj.insert(currParent!.localObject(), at: 0)
			
			currParent = currParent?.parentPathable()
		}
		
		// add local path
		str += pathable.localPath()
		obj.append(pathable.localObject())
		
		return (str, obj)
	}
}
