//
//  NVBranch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBranch : NVBaseLink {
	// MARK: - Variables -
	private var _preCondition: NVCondition
	private var _condition: NVCondition
	private var _trueTransfer: NVTransfer
	private var _falseTransfer: NVTransfer
	
	// MARK: - Properties -
	public var PreCondition: NVCondition {
		get{ return _preCondition }
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
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		self._preCondition = NVCondition(manager: manager)
		self._condition = NVCondition(manager: manager)
		self._trueTransfer = NVTransfer(manager: manager)
		self._falseTransfer = NVTransfer(manager: manager)
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	// MARK: - Functions -
	public func setTrueDestination(dest: NVObject?) {
		if dest != nil && !(dest!.isLinkable()) {
			NVLog.log("Could not set Branch's true destination as the Object was not linkable (\(dest?.UUID.uuidString)).", level: .warning)
			return
		}
		_trueTransfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryBranchSetTrueDestination(branch: self, dest: dest)}
	}
	
	public func setFalseDestination(dest: NVObject?) {
		if dest != nil && !(dest!.isLinkable()) {
			NVLog.log("Could not set Branch's false destination as the Object was not linkable (\(dest?.UUID.uuidString)).", level: .warning)
			return
		}
		_falseTransfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryBranchSetFalseDestination(branch: self, dest: dest)}
	}
}
