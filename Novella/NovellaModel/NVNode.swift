//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode: NVObject {
	// MARK: - Variables -
	private var _name: String
	
	// MARK: - Properties -
	public var Name: String {
		get { return _name }
		set {
			let oldName = _name
			_name = newValue
			_manager.Delegates.forEach{$0.onStoryNodeNameChanged(oldName: oldName, newName: _name, node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._name = ""
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return true
	}
}
