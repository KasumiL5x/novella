//
//  NVSelector.swift
//  novella
//
//  Created by Daniel Green on 21/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

class NVSelector: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	
	var Code: String = "" {
		didSet {
			_story.Observers.forEach{$0.nvSelectorCodeDidChange(story: _story, selector: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
	}
}

extension NVSelector: Equatable {
	static func == (lhs: NVSelector, rhs: NVSelector) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
