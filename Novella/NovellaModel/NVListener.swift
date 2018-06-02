//
//  NVListener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVListener: NVNode {
	private let _condition: NVCondition
	private let _transfer: NVTransfer
	
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._condition = NVCondition(manager: manager)
		self._transfer = NVTransfer()
		
		super.init(manager: manager, uuid: uuid)
	}
}
