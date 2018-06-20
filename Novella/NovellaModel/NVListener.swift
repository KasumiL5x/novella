//
//  NVListener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVListener: NVNode {
	// MARK: - Variables -
	private let _condition: NVCondition
	private let _transfer: NVTransfer
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._condition = NVCondition(manager: manager)
		self._transfer = NVTransfer(manager: manager)
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return false // Listeners are floating 'root' objects and cannot be linked to.
	}
}
