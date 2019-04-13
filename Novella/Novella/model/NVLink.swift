//
//  NVLink.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVLink: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	
	private(set) var Origin: NVLinkable
	//
	var Destination: NVLinkable? {
		didSet {
			NVLog.log("Link (\(UUID.uuidString)) Destination changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Destination?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvLinkDestinationChanged(story: _story, link: self)}
		}
	}
	//
	var Condition: NVCondition?
	var Function: NVFunction?
	
	init(uuid: NSUUID, story: NVStory, origin: NVLinkable, destination: NVLinkable?) {
		self.UUID = uuid
		self._story = story
		self.Origin = origin
		self.Destination = destination
		self.Condition = nil
		self.Function = nil
		
		if !origin.canBecomeOrigin() {
			fatalError("Tried to create link with a Linkable that cannot become an origin.")
		}
	}
}

extension NVLink: Equatable {
	static func == (lhs: NVLink, rhs: NVLink) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
