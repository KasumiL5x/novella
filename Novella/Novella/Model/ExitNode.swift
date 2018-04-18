//
//  ExitNode.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class ExitNode {
	let _uuid: NSUUID
	
	init(uuid: NSUUID) {
		self._uuid = uuid
	}
}

// MARK: Identifiable
extension ExitNode: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Linkable
extension ExitNode: Linkable {
}

// MARK: Equatable
extension ExitNode: Equatable {
	static func == (lhs: ExitNode, rhs: ExitNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
