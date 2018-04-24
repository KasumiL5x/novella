//
//  Transfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Transfer {
	var _destination: Linkable?
	var _function: Function
	
	init() {
		self._destination = nil
		self._function = Function()
	}
	
	func setDestination(dest: Linkable?) {
		self._destination = dest
	}
}
