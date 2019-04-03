//
//  NVLink.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

typealias NVSequenceLink = NVLink<NVSequence>
typealias NVEventLink = NVLink<NVEvent>

class NVLink<T>: NVIdentifiable where T: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	
	private(set) var Origin: T
	//
	var Destination: T? {
		didSet {
			NVLog.log("Link (\(UUID.uuidString)) Destination changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Destination?.UUID.uuidString ?? "nil")).", level: .info)
			
			// a bit hacky but watcha' gonna do with templates like these?
			if self is NVSequenceLink {
				_story.Observers.forEach{$0.nvSequenceLinkDestinationDidChange(story: _story, link: self as! NVSequenceLink)}
			}
			if self is NVEventLink {
				_story.Observers.forEach{$0.nvEventLinkDestinationDidChange(story: _story, link: self as! NVEventLink)}
			}
		}
	}
	//
	var Condition: NVCondition?
	var Function: NVFunction?
	
	init(uuid: NSUUID, story: NVStory, origin: T, destination: T?) {
		self.UUID = uuid
		self._story = story
		self.Origin = origin
		self.Destination = destination
		self.Condition = nil
		self.Function = nil
	}
}

extension NVLink: Equatable {
	static func == (lhs: NVLink, rhs: NVLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
