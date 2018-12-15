//
//  NVLink.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

typealias NVBeatLink = NVLink<NVBeat>
typealias NVEventLink = NVLink<NVEvent>

class NVLink<T>: NVIdentifiable where T: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	private(set) var Origin: T
	var Destination: T? {
		didSet {
			if let dest = Destination, Origin.UUID == dest.UUID {
				Destination = nil
				NVLog.log("Tried to set Link (\(UUID.uuidString)) Destination to its Origin.", level: .warning)
			} else {
				NVLog.log("Link (\(UUID.uuidString)) Destination changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Destination?.UUID.uuidString ?? "nil")).", level: .info)
			}
			
			// a bit hacky but watcha' gonna do with templates like these?
			if self is NVBeatLink {
				_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatLinkDestinationDidChange(story: _story, link: self as! NVBeatLink)}
			}
			if self is NVEventLink {
				_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvEventLinkDestinationDidChange(story: _story, link: self as! NVEventLink)}
			}
		}
	}
	var Function: NVFunction
	
	init(uuid: NSUUID, story: NVStory, origin: T, destination: T?) {
		self.UUID = uuid
		self._story = story
		self.Origin = origin
		self.Destination = destination
		self.Function = NVFunction(story: story)
	}
}

extension NVLink: Equatable {
	static func == (lhs: NVLink, rhs: NVLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
