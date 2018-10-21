//
//  NVPath.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

protocol NVPathable {
	func localPath() -> String
	func parentPathable() -> NVPathable?
}

class NVPath {
	static let DELIM = "."
	
	static func fullPath(_ pathable: NVPathable) -> String {
		var str = ""
		
		// add parent paths with delimiter
		var currParent = pathable.parentPathable()
		while currParent != nil {
			str = (currParent!.localPath() + NVPath.DELIM) + str // add reverse order b/c we're going bottom up
			currParent = currParent?.parentPathable()
		}
		
		// add local path
		str += pathable.localPath()
		
		return str
	}
}
