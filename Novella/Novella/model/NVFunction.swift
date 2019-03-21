//
//  NVFunction.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVFunction: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	var Code: String = "" {
		didSet {
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvFunctionCodeDidChange(story: _story, function: self)}
		}
	}
	private(set) var FunctionName: String
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.FunctionName = "nvFunction" + NVUtil.randomString(length: 10)
	}
}

extension NVFunction: Equatable {
	static func == (lhs: NVFunction, rhs: NVFunction) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
