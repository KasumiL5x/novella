//
//  Branch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Branch : BaseLink {
	var _condition: Condition
	var _trueTransfer: Transfer
	var _falseTransfer: Transfer
	
	override init(uuid: NSUUID) {
		self._condition = Condition()
		self._trueTransfer = Transfer()
		self._falseTransfer = Transfer()
		
		super.init(uuid: uuid)
	}
}
