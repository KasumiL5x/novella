//
//  NVListener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVListener: NVNode {
	fileprivate let _condition: NVCondition
	fileprivate let _transfer: NVTransfer
	
	override init(uuid: NSUUID) {
		self._condition = NVCondition()
		self._transfer = NVTransfer()
		
		super.init(uuid: uuid)
	}
}
