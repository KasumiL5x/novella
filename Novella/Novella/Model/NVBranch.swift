//
//  Branch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVBranch : NVBaseLink {
	var _condition: Condition
	var _trueTransfer: Transfer
	var _falseTransfer: Transfer
	
	override init(uuid: NSUUID, story: Story) {
		self._condition = Condition(story: story)
		self._trueTransfer = Transfer()
		self._falseTransfer = Transfer()
		
		super.init(uuid: uuid, story: story)
	}
}
