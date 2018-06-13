//
//  NVObject.swift
//  NovellaModel
//
//  Created by Daniel Green on 13/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVObject {
	// MARK: - Variables -
	internal var _manager: NVStoryManager
	private var _uuid: NSUUID
	private var _inTrash: Bool
	private var _position: CGPoint
	
	// MARK: - Properties -
	public var Manager: NVStoryManager {
		get{ return _manager }
	}
	public var UUID: NSUUID {
		get{ return _uuid }
	}
	public var InTrash: Bool {
		get{ return _inTrash }
	}
	public var Position: CGPoint {
		get{ return _position }
		set {
			let oldPos = _position
			_position = newValue
			_manager.Delegates.forEach{$0.onStoryObjectPositionChanged(obj: self, oldPos: oldPos, newPos: _position)}
		}
	}
	
	init(manager: NVStoryManager, uuid: NSUUID) {
		self._manager = manager
		self._uuid = uuid
		self._inTrash = false
		self._position = CGPoint.zero
	}
	
	// MARK: - Trashing -
	public func trash() {
		_inTrash = true
		_manager.trash(self)
	}
	public func untrash() {
		_inTrash = false
		_manager.untrash(self)
	}
	
	// MARK: - Linking -
	public func isLinkable() -> Bool {
		print("NVObject::isLinkable() should be overridden (\(self)).")
		return false
	}
}

// MARK: - Equatable -
extension NVObject: Equatable {
	public static func == (lhs: NVObject, rhs: NVObject) -> Bool {
		return lhs._uuid == rhs._uuid
	}
}
