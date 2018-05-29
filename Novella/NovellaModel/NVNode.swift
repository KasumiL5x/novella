//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode {
	fileprivate let _uuid: NSUUID
	fileprivate var _inTrash: Bool
	fileprivate var _editorPos: CGPoint
	
	fileprivate var _name: String
	
	init(uuid: NSUUID) {
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
			NVStoryManager.shared.Delegates.forEach{$0.onStoryNodeNameChanged(oldName: oldName, newName: _name, node: self)}
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
				NVStoryManager.shared.trash(self)
			} else {
				_inTrash = false
				NVStoryManager.shared.untrash(self)
			}
		}
	}
	
	public var EditorPosition: CGPoint {
		get { return _editorPos }
		set { _editorPos = newValue }
	}
}

// MARK: - Equatable -
extension NVNode: Equatable {
	public static func == (lhs: NVNode, rhs: NVNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
