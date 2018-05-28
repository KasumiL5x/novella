//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode {
	let _uuid: NSUUID
	var _name: String
	var _inTrash: Bool
	
	var _editorPos: CGPoint
	
	var _delegates: [NVStoryDelegate]
	var _storyManager: NVStoryManager
	
	init(uuid: NSUUID, storyManager: NVStoryManager) {
		self._uuid = uuid
		self._name = ""
		self._inTrash = false
		self._editorPos = CGPoint.zero
		self._delegates = []
		self._storyManager = storyManager
	}
	
	// MARK: Properties
	public var Name: String {
		get { return _name }
		set {
			let oldName = _name
			_name = newValue
			_delegates.forEach{$0.onStoryNodeNameChanged(oldName: oldName, newName: _name, node: self)}
		}
	}
}

// MARK: NVTrashable
extension NVNode: NVTrashable {
	public func trash() {
		_storyManager.trash(self)
		_inTrash = true
	}
	
	public func untrash() {
		_inTrash = false
	}
	
	public func inTrash() -> Bool {
		return _inTrash
	}
}

// MARK: NVIdentifiable
extension NVNode: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: NVLinkable
extension NVNode: NVLinkable {
	public var EditorPosition: CGPoint {
		get {
			return _editorPos
		}
		set {
			_editorPos = newValue
		}
	}
	
}

// MARK: Equatable
extension NVNode: Equatable {
	public static func == (lhs: NVNode, rhs: NVNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
