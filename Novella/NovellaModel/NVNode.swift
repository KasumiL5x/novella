//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode: NVBaseObject {
	let _uuid: NSUUID
	var _name: String
	
	override init(uuid: NSUUID, storyManager: NVStoryManager) {
		self._uuid = uuid
		self._name = ""
		super.init(uuid: uuid, storyManager: storyManager)
	}
	
	// MARK: Properties
	public var Name: String {
		get { return _name }
		set {
			let oldName = _name
			_name = newValue
			Delegates.forEach{$0.onStoryNodeNameChanged(oldName: oldName, newName: _name, node: self)}
		}
	}
}
