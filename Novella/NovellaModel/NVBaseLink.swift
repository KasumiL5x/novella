//
//  NVBaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseLink {
	let _uuid: NSUUID
	var _origin: NVLinkable
	
	init(uuid: NSUUID, storyManager: NVStoryManager, origin: NVLinkable) {
		self._uuid = uuid
		self._origin = origin
	}
	
	// MARK: Properties
	public var Origin: NVLinkable {get{ return _origin }}
}

// MARK: NVIdentifiable
extension NVBaseLink: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVBaseLink: Equatable {
	public static func == (lhs: NVBaseLink, rhs: NVBaseLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
