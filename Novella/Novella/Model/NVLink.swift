//
//  NVLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVLink : NVBaseLink {
	var _condition: NVCondition
	var _transfer: NVTransfer
	
	override init(uuid: NSUUID, story: NVStory) {
		self._condition = NVCondition(story: story)
		self._transfer = NVTransfer()
		
		super.init(uuid: uuid, story: story)
	}
}
