//
//  NVLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLink : NVBaseLink {
	var _condition: NVCondition
	var _transfer: NVTransfer
	
	override init(uuid: NSUUID, storyManager: NVStoryManager, origin: NVLinkable) {
		self._condition = NVCondition(storyManager: storyManager)
		self._transfer = NVTransfer()
		
		super.init(uuid: uuid, storyManager: storyManager, origin: origin)
	}
	
	// MARK: Properties
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
	public var Condition: NVCondition {
		get{ return _condition }
	}
}
