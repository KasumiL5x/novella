//
//  NVBranch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBranch : NVBaseLink {
	private var _condition: NVCondition
	private var _trueTransfer: NVTransfer
	private var _falseTransfer: NVTransfer
	
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._condition = NVCondition(manager: manager)
		self._trueTransfer = NVTransfer()
		self._falseTransfer = NVTransfer()
		
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	public var Condition: NVCondition {
		get{ return _condition }
	}
	public var TrueTransfer:  NVTransfer {
		get{ return _trueTransfer }
	}
	public var FalseTransfer: NVTransfer {
		get{ return _falseTransfer }
	}
	
	public func setTrueDestination(dest: NVLinkable?) {
		_trueTransfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryBranchSetTrueDestination(branch: self, dest: dest)}
	}
	
	public func setFalseDestination(dest: NVLinkable?) {
		_falseTransfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryBranchSetFalseDestination(branch: self, dest: dest)}
	}
}
