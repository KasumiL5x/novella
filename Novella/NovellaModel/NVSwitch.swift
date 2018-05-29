//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	fileprivate var _variable: NVVariable?
	fileprivate var _defaultTransfer: NVTransfer
	fileprivate var _values: [AnyHashable:NVTransfer]
	
	override init(uuid: NSUUID, storyManager: NVStoryManager, origin: NVLinkable) {
		self._variable = nil
		self._defaultTransfer = NVTransfer()
		self._values = [:]
		
		super.init(uuid: uuid, storyManager: storyManager, origin: origin)
	}
}
