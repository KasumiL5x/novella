//
//  Transfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class NVTransfer {
	var _destination: NVLinkable?
	var _function: NVFunction
	
	init() {
		self._destination = nil
		self._function = NVFunction()
	}
	
	func setDestination(dest: NVLinkable?) {
		self._destination = dest
	}
}
