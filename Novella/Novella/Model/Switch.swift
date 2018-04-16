//
//  Switch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Switch : BaseLink {
	var variable: Variable?
	var defaultTransfer: Transfer
	var values: [AnyHashable:Transfer]
	
	override init() {
		self.variable = nil
		self.defaultTransfer = Transfer()
		self.values = [:]
	}
}
