//
//  BaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVBaseLink {
	let _uuid: NSUUID
	var _origin: NVLinkable?
	
	init(uuid: NSUUID, story: Story) {
		self._uuid = uuid
		self._origin = nil
	}
	
	func setOrigin(origin: NVLinkable?) {
		self._origin = origin
	}
}

// MARK: Identifiable
extension NVBaseLink: NVIdentifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVBaseLink: Equatable {
	static func == (lhs: NVBaseLink, rhs: NVBaseLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
