//
//  FlowNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class FlowNode {
	let _uuid: NSUUID
	var _name: String
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self._name = ""
	}
	
	// MARK: Properties
	var Name: String {get{ return _name } set{ _name = newValue }}
}

// MARK: Identifiable
extension FlowNode: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension FlowNode: Equatable {
	static func == (lhs: FlowNode, rhs: FlowNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}

// MARK: Linkable
extension FlowNode: Linkable {
}
