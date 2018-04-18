//
//  BaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class BaseLink {
	let _uuid: NSUUID
	var origin: Linkable?
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self.origin = nil
	}
}

// MARK: Identifiable
extension BaseLink: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension BaseLink: Equatable {
	static func == (lhs: BaseLink, rhs: BaseLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
