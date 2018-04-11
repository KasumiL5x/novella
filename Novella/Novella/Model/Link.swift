//
//  Link.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Link : BaseLink {
	var condition: Condition
	var transfer: Transfer
	
	override init() {
		self.condition = Condition()
		self.transfer = Transfer()
	}
}
