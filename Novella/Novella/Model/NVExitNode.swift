//
//  ExitNode.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVExitNode {
	let _uuid: NSUUID
	
	init(uuid: NSUUID) {
		self._uuid = uuid
	}
}

// MARK: Identifiable
extension NVExitNode: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Linkable
extension NVExitNode: Linkable {
}

// MARK: Equatable
extension NVExitNode: Equatable {
	static func == (lhs: NVExitNode, rhs: NVExitNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
