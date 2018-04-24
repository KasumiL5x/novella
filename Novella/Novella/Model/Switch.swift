//
//  Switch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation


class Switch : BaseLink {
	var _variable: Variable?
	var _defaultTransfer: Transfer
	var _values: [AnyHashable:Transfer]
	
	override init(uuid: NSUUID) {
		self._variable = nil
		self._defaultTransfer = Transfer()
		self._values = [:]
		
		super.init(uuid: uuid)
	}
}
