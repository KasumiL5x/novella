//
//  NVEntity.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVEntity: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	var Label: String {
		didSet {
			_story.Observers.forEach{$0.nvEntityLabelDidChange(story: _story, entity: self)}
		}
	}
	var Description: String {
		didSet {
			_story.Observers.forEach{$0.nvEntityDescriptionDidChange(story: _story, entity: self)}
		}
	}
	var Tags: [String] {
		didSet {
			_story.Observers.forEach{$0.nvEntityTagsDidChange(story: _story, entity: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = ""
		self.Description = ""
		self.Tags = []
	}
}

extension NVEntity: Equatable {
	static func == (lhs: NVEntity, rhs: NVEntity) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
