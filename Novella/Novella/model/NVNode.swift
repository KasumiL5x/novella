//
//  NVNode.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVNode: NVIdentifiable, NVLinkable {
	// MARK: - Variables
	var ID: NSUUID
	var _story: NVStory // no protected, so it's just public
	
	// MARK: - Properties
	var Name: String = "" {
		didSet {
			NVLog.log("Node (\(ID)) renamed (\(oldValue)->\(Name)).", level: .info)
			_story.Delegates.forEach{$0.nvNodeDidRename(node: self)}
		}
	}
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory) {
		self.ID = id
		self._story = story
	}
}

extension NVNode: Equatable {
	static func ==(lhs: NVNode, rhs: NVNode) -> Bool {
		return lhs.ID == rhs.ID
	}
}
