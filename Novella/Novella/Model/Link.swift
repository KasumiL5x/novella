//
//  Link.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Link : BaseLink {
	var _condition: Condition
	var _transfer: Transfer
	
	override init(uuid: NSUUID) {
		self._condition = Condition()
		self._transfer = Transfer()
		
		super.init(uuid: uuid)
	}
}
