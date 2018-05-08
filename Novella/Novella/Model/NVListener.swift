//
//  Listener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVListener {
	let _uuid: NSUUID
	let _condition: NVCondition
	let _transfer: NVTransfer
	
	init(uuid: NSUUID, story: Story) {
		self._uuid = uuid
		self._condition = NVCondition(story: story)
		self._transfer = NVTransfer()
	}
}

// MARK: Identifiable
extension NVListener: NVIdentifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVListener: Equatable {
	static func == (lhs: NVListener, rhs: NVListener) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
