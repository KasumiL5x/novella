//
//  Link.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Link : BaseLink {
	var condition: Condition
	var transfer: Transfer
	
	override init(uuid: NSUUID) {
		self.condition = Condition()
		self.transfer = Transfer()
		
		super.init(uuid: uuid)
	}
}
