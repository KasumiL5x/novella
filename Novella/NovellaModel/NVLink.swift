//
//  NVLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLink : NVBaseLink {
	private var _condition: NVCondition
	private var _transfer: NVTransfer
	
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._condition = NVCondition(manager: manager)
		self._transfer = NVTransfer()
		
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
	public var Condition: NVCondition {
		get{ return _condition }
	}
	
	public func setDestination(dest: NVLinkable?) {
		_transfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryLinkSetDestination(link: self, dest: dest)}
	}
}
