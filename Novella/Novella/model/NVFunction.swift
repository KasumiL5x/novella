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
			_story.Observers.forEach{$0.nvFunctionCodeDidChange(story: _story, function: self)}
		}
	}
	var Label: String {
		didSet {
			NVLog.log("Function (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvFunctionLabelDidChange(story: _story, function: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = "nvFunction" + NVUtil.randomString(length: 10)
	}
}

extension NVFunction: Equatable {
	static func == (lhs: NVFunction, rhs: NVFunction) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
