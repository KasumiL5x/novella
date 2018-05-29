//
//  NVBranch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBranch : NVBaseLink {
	fileprivate var _condition: NVCondition
	fileprivate var _trueTransfer: NVTransfer
	fileprivate var _falseTransfer: NVTransfer
	
	override init(uuid: NSUUID, storyManager: NVStoryManager, origin: NVLinkable) {
		self._condition = NVCondition(storyManager: storyManager)
		self._trueTransfer = NVTransfer()
		self._falseTransfer = NVTransfer()
		
		super.init(uuid: uuid, storyManager: storyManager, origin: origin)
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
		_storyManager.Delegates.forEach{$0.onStoryBranchSetTrueDestination(branch: self, dest: dest)}
	}
	
	public func setFalseDestination(dest: NVLinkable?) {
		_falseTransfer._destination = dest
		_storyManager.Delegates.forEach{$0.onStoryBranchSetFalseDestination(branch: self, dest: dest)}
	}
}
