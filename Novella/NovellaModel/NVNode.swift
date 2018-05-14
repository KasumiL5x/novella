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
	
	var _editorPos: CGPoint
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self._name = ""
		self._editorPos = CGPoint.zero
	}
	
	// MARK: Properties
	public var Name: String {get{ return _name } set{ _name = newValue }}
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
