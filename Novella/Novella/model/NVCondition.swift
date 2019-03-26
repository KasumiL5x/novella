//
//  NVCondition.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVCondition: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	var Code: String = "return true;" {
		didSet {
			if Code.isEmpty {
				Code = "return true;"
			}
			_story.Observers.forEach{$0.nvConditionCodeDidChange(story: _story, condition: self)}
		}
	}
	var Label: String {
		didSet {
			NVLog.log("Condition (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvConditionLabelDidChange(story: _story, condition: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = "nvCondition" + NVUtil.randomString(length: 10)
	}

}

extension NVCondition: Equatable {
	static func == (lhs: NVCondition, rhs: NVCondition) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
