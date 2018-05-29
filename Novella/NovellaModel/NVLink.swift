//
//  NVLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLink : NVBaseLink {
	fileprivate var _condition: NVCondition
	fileprivate var _transfer: NVTransfer
	
	override init(uuid: NSUUID, origin: NVLinkable) {
		self._condition = NVCondition()
		self._transfer = NVTransfer()
		
		super.init(uuid: uuid, origin: origin)
	}
	
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
	public var Condition: NVCondition {
		get{ return _condition }
	}
	
	public func setDestination(dest: NVLinkable?) {
		_transfer._destination = dest
		NVStoryManager.shared.Delegates.forEach{$0.onStoryLinkSetDestination(link: self, dest: dest)}
	}
}
