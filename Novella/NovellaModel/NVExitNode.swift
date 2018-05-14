//
//  NVExitNode.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVExitNode {
	let _uuid: NSUUID
	var _editorPos: CGPoint
	
	init(uuid: NSUUID) {
		self._uuid = uuid
		self._editorPos = CGPoint.zero
	}
}

// MARK: NVIdentifiable
extension NVExitNode: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: NVLinkable
extension NVExitNode: NVLinkable {
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
extension NVExitNode: Equatable {
	public static func == (lhs: NVExitNode, rhs: NVExitNode) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
