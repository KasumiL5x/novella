//
//  NVBaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseLink {
	internal let _manager: NVStoryManager
	private let _uuid: NSUUID
	private var _origin: NVLinkable
	
	init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._manager = manager
		self._uuid = uuid
		self._origin = origin
	}
	
	public var Origin: NVLinkable {
		get{ return _origin }
	}
}

// MARK: - NVIdentifiable -
extension NVBaseLink: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: - Equatable -
extension NVBaseLink: Equatable {
	public static func == (lhs: NVBaseLink, rhs: NVBaseLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
