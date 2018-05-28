//
//  NVBaseObject.swift
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVBaseObject {
	fileprivate let _uuid: NSUUID
	fileprivate var _inTrash: Bool
	fileprivate var _editorPos: CGPoint
	fileprivate var _delegates: [NVStoryDelegate]
	let _storyManager: NVStoryManager
	
	init(uuid: NSUUID, storyManager: NVStoryManager) {
		self._uuid = uuid
		self._inTrash = false
		self._editorPos = CGPoint.zero
		self._delegates = []
		self._storyManager = storyManager
	}
	
	public var Delegates: [NVStoryDelegate] {
		get{ return _delegates }
		set{ _delegates = newValue }
	}
}

// MARK: - - NVIdentifiable -
extension NVBaseObject: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: - - NVTrashable -
extension NVBaseObject: NVTrashable {
	public func inTrash() -> Bool {
		return _inTrash
	}
	
	public func trash() {
		_inTrash = true
		_storyManager.trash(self)
	}
	
	public func untrash() {
		_inTrash = false
		_storyManager.untrash(self)
	}
}

// MARK: - - NVLinkable -
extension NVBaseObject: NVLinkable {
	public var EditorPosition: CGPoint {
		get { return _editorPos }
		set { _editorPos = newValue }
	}
}

// MARK: - - Equatable -
extension NVBaseObject: Equatable {
	public static func == (lhs: NVBaseObject, rhs: NVBaseObject) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
