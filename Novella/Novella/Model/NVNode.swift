//
//  FlowNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVNode {
	let _uuid: NSUUID
	var _name: String
	
	var _editorPos: CGPoint
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self._name = ""
		self._editorPos = CGPoint.zero
	}
	
	// MARK: Properties
	var Name: String {get{ return _name } set{ _name = newValue }}
}

// MARK: Identifiable
extension NVNode: NVIdentifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVNode: Equatable {
	static func == (lhs: NVNode, rhs: NVNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}

// MARK: Linkable
extension NVNode: Linkable {
}
