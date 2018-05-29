//
//  NVBaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseLink {
	fileprivate let _uuid: NSUUID
	fileprivate var _origin: NVLinkable
	internal var _storyManager: NVStoryManager
	
	init(uuid: NSUUID, storyManager: NVStoryManager, origin: NVLinkable) {
		self._uuid = uuid
		self._origin = origin
		self._storyManager = storyManager
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
