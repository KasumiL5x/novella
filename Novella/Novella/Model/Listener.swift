//
//  Listener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Listener {
	let _uuid: NSUUID
	let _condition: Condition
	let _transfer: Transfer
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self._condition = Condition()
		self._transfer = Transfer()
	}
}

// MARK: Identifiable
extension Listener: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension Listener: Equatable {
	static func == (lhs: Listener, rhs: Listener) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
