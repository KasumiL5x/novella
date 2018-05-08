//
//  NVDialog.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVDialog: NVNode {
	var _content: String
	var _preview: String
	var _directions: String
	
	override init(uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid)
	}
	
	// MARK: Setters
	func setContent(content: String) {
		self._content = content
	}
	
	func setPreview(preview: String) {
		self._preview = preview
	}
	
	func setDirections(directions: String) {
		self._directions = directions
	}
}
