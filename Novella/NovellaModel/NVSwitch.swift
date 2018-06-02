//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	private var _variable: NVVariable?
	private var _defaultTransfer: NVTransfer
	private var _values: [AnyHashable:NVTransfer]
	
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._variable = nil
		self._defaultTransfer = NVTransfer()
		self._values = [:]
		
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
}
