//
//  NVLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLink : NVBaseLink {
	// MARK: - Variables -
	private var _preCondition: NVCondition
	private var _transfer: NVTransfer
	
	// MARK: - Properties -
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
	public var PreCondition: NVCondition {
		get{ return _preCondition }
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		self._preCondition = NVCondition(manager: manager)
		self._transfer = NVTransfer(manager: manager)
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	// MARK: - Functions -
	public func setDestination(dest: NVObject?) {
		if dest != nil && !(dest!.isLinkable()) {
			print("NVLink.setDestination was given a non-linkable NVObject.  The request was ignored.")
			return
		}
		_transfer._destination = dest
		_manager.Delegates.forEach{$0.onStoryLinkSetDestination(link: self, dest: dest)}
	}
}
