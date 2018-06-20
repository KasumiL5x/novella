//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	// MARK: - Variables -
	private var _variable: NVVariable?
	private var _defaultTransfer: NVTransfer
	private var _values: [AnyHashable:NVTransfer]
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		self._variable = nil
		self._defaultTransfer = NVTransfer(manager: manager)
		self._values = [:]
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
}
