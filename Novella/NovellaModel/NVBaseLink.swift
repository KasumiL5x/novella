//
//  NVBaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseLink: NVObject {
	// MARK: - Variables -
	private var _origin: NVObject
	
	// MARK: - Properties -
	public var Origin: NVObject {
		get{ return _origin }
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		if !origin.isLinkable() {
			NVLog.log("BaseLink initialized with a non-linkable NVObject.  This should never happen.  Contact your local programmer and DON'T PANIC!", level: .error)
			fatalError()
		}
		self._origin = origin
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return false
	}
}
