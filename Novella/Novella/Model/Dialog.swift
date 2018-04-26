//
//  Dialog.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Dialog: FlowNode {
	var _content: String
	var _preview: String
	var _directions: String
	
	
	override init(uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid)
	}
}
