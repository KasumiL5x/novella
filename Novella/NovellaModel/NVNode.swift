//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode {
	internal let _manager: NVStoryManager
	private let _uuid: NSUUID
	private var _inTrash: Bool
	private var _editorPos: CGPoint
	
	private var _name: String
	
	init(manager: NVStoryManager, uuid: NSUUID) {
		self._manager = manager
		self._uuid = uuid
		self._inTrash = false
		self._editorPos = CGPoint.zero
		
		self._name = ""
	}
	
	public var Name: String {
		get { return _name }
		set {
			let oldName = _name
			_name = newValue
			_manager.Delegates.forEach{$0.onStoryNodeNameChanged(oldName: oldName, newName: _name, node: self)}
		}
	}
}

// MARK: - NVIdentifiable -
extension NVNode: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: - NVLinkable -
extension NVNode: NVLinkable {
	public var Trashed: Bool {
		get { return _inTrash }
		set {
			if newValue {
				_inTrash = true
				_manager.trash(self)
			} else {
				_inTrash = false
				_manager.untrash(self)
			}
		}
	}
	
	public var EditorPosition: CGPoint {
		get { return _editorPos }
		set {
			let oldPos = _editorPos
			_editorPos = newValue
			_manager.Delegates.forEach{$0.onStoryNodePositionChanged(node: self, oldPos: oldPos, newPos: _editorPos)}
		}
	}
}

// MARK: - Equatable -
extension NVNode: Equatable {
	public static func == (lhs: NVNode, rhs: NVNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
