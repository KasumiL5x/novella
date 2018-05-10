//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	var _variable: NVVariable?
	var _defaultTransfer: NVTransfer
	var _values: [AnyHashable:NVTransfer]
	
	override init(uuid: NSUUID, story: NVStory, origin: NVLinkable) {
		self._variable = nil
		self._defaultTransfer = NVTransfer()
		self._values = [:]
		
		super.init(uuid: uuid, story: story, origin: origin)
	}
}
