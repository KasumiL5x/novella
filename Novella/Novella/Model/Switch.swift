//
//  Switch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation


class Switch : BaseLink {
	var variable: Variable?
	var defaultTransfer: Transfer
	var values: [AnyHashable:Transfer]
	
	override init(uuid: NSUUID) {
		self.variable = nil
		self.defaultTransfer = Transfer()
		self.values = [:]
		
		super.init(uuid: uuid)
	}
}
