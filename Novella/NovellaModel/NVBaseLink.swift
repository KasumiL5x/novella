//
//  NVBaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseLink: NSObject, NSCoding {
	internal let _manager: NVStoryManager
	private let _uuid: NSUUID
	private var _origin: NVLinkable
	
	init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._manager = manager
		self._uuid = uuid
		self._origin = origin
		super.init()
	}
	
	// MARK: Coding
	public override func isEqual(_ object: Any?) -> Bool {
		return self._uuid == (object as? NVBaseLink)?._uuid
	}
	public required init?(coder aDecoder: NSCoder) {
		self._manager = aDecoder.decodeObject(forKey: "_manager") as! NVStoryManager
		self._uuid = aDecoder.decodeObject(forKey: "_uuid") as! NSUUID
		self._origin = aDecoder.decodeObject(forKey: "_origin") as! NVLinkable
	}
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(_manager, forKey: "_manager")
		aCoder.encode(_uuid, forKey: "_uuid")
		aCoder.encode(_origin, forKey: "_origin")
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
