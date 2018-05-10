//
//  NVBranch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBranch : NVBaseLink {
	var _condition: NVCondition
	var _trueTransfer: NVTransfer
	var _falseTransfer: NVTransfer
	
	override init(uuid: NSUUID, story: NVStory, origin: NVLinkable) {
		self._condition = NVCondition(story: story)
		self._trueTransfer = NVTransfer()
		self._falseTransfer = NVTransfer()
		
		super.init(uuid: uuid, story: story, origin: origin)
	}
	
	// MARK: Getters
	public var TrueTransfer: NVTransfer {
		get{ return _trueTransfer }
	}
	public var FalseTransfer: NVTransfer {
		get{ return _falseTransfer }
	}
}
