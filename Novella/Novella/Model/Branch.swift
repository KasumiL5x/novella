//
//  Branch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Branch : BaseLink {
	var condition: Condition
	var trueTransfer: Transfer
	var falseTransfer: Transfer
	
	override init() {
		self.condition = Condition()
		self.trueTransfer = Transfer()
		self.falseTransfer = Transfer()
	}
}
