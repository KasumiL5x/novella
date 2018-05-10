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
	
	override init(uuid: NSUUID, story: NVStory, origin: NVLinkable) {
		self._condition = NVCondition(story: story)
		self._transfer = NVTransfer()
		
		super.init(uuid: uuid, story: story, origin: origin)
	}
	
	// MARK: Getters
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
}
