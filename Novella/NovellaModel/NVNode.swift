//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode: NSObject, NSCoding {
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
		super.init()
	}
	
	// MARK: Coding
	public override func isEqual(_ object: Any?) -> Bool {
		return self._uuid == (object as? NVNode)?._uuid
	}
	public required init?(coder aDecoder: NSCoder) {
		self._manager = aDecoder.decodeObject(forKey: "_manager") as! NVStoryManager
		self._uuid = aDecoder.decodeObject(forKey: "_uuid") as! NSUUID
		self._inTrash = aDecoder.decodeObject(forKey: "_inTrash") as! Bool
		self._editorPos = aDecoder.decodeObject(forKey: "_editorPos") as! CGPoint
		self._name = aDecoder.decodeObject(forKey: "_name") as! String
	}
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(_manager, forKey: "_manager")
		aCoder.encode(_uuid, forKey: "_uuid")
		aCoder.encode(_inTrash, forKey: "_inTrash")
		aCoder.encode(_editorPos, forKey: "_editorPos")
		aCoder.encode(_name, forKey: "_name")
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
		get {
			return _editorPos
		}
		set {
			let oldPos = _editorPos
			_editorPos = newValue
			_manager.Delegates.forEach{$0.onStoryNodePositionChanged(node: self, oldPos: oldPos, newPos: _editorPos)}
		}
	}
}
