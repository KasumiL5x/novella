//
//  NVBeat.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVBeat: NVIdentifiable {
	var UUID: NSUUID
	let _story: NVStory
	var Parent: NVGroup? // warning: no friend class support so has to be public
	var Label: String {
		didSet {
			NVLog.log("Beat (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatLabelDidChange(story: _story, beat: self)}
		}
	}
	var Parallel: Bool {
		didSet {
			NVLog.log("Beat (\(UUID.uuidString)) Parallel changed (\(oldValue) -> \(Parallel)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatParallelDidChange(story: _story, beat: self)}
		}
	}
	var PreCondition: NVCondition
	var EntryFunction: NVFunction
	var ExitFunction: NVFunction
	var Entry: NVEvent? {
		didSet {
			// must be part of the beat
			if let entry = Entry, !contains(event: entry) {
				Entry = nil
				NVLog.log("Tried to set Beat (\(UUID.uuidString)) Entry to a non-included Entry.", level: .warning)
			} else {
				NVLog.log("Beat (\(UUID.uuidString)) Entry changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Entry?.UUID.uuidString ?? "nil")).", level: .info)
			}
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatEntryDidChange(story: _story, beat: self, oldEntry: oldValue, newEntry: Entry)}
		}
	}
	private(set) var Events: [NVEvent]
	private(set) var EventLinks: [NVEventLink]
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Parent = nil
		self.Label = ""
		self.Parallel = false
		self.PreCondition = NVCondition(story: story)
		self.EntryFunction = NVFunction(story: story)
		self.ExitFunction = NVFunction(story: story)
		self.Entry = nil
		self.Events = []
		self.EventLinks = []
	}
	
	func contains(event: NVEvent) -> Bool {
		return Events.contains(event)
	}
	func add(event: NVEvent) {
		if contains(event: event) {
			NVLog.log("Tried to add Event (\(event.UUID.uuidString)) to Beat (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Events.append(event)
		event.Parent = self
		
		NVLog.log("Added Event (\(event.UUID.uuidString)) to Beat (\(UUID.uuidString)).", level: .info)
		_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatDidAddEvent(story: _story, beat: self, event: event)}
	}
	func remove(event: NVEvent) {
		guard let idx = Events.index(of: event) else {
			NVLog.log("Tried to remove Event (\(event.UUID.uuidString)) from Beat (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Events.remove(at: idx)
		event.Parent = nil
		
		NVLog.log("Removed Event (\(event.UUID.uuidString)) from Beat (\(UUID.uuidString)).", level: .info)
		_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatDidRemoveEvent(story: _story, beat: self, event: event)}
		
		if Entry == event {
			Entry = nil
		}
	}
	
	func contains(eventLink: NVEventLink) -> Bool {
		return EventLinks.contains(eventLink)
	}
	func add(eventLink: NVEventLink) {
		if contains(eventLink: eventLink) {
			NVLog.log("Tried to add EventLink (\(eventLink.UUID.uuidString)) to Beat (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		EventLinks.append(eventLink)
		NVLog.log("Added EventLink (\(eventLink.UUID.uuidString)) to Beat (\(UUID.uuidString)).", level: .info)
		_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatDidAddEventLink(story: _story, beat: self, link: eventLink)}
	}
	func remove(eventLink: NVEventLink) {
		guard let idx = EventLinks.index(of: eventLink) else {
			NVLog.log("Tried to remove EventLink (\(eventLink.UUID.uuidString)) from Beat (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		EventLinks.remove(at: idx)
		NVLog.log("Removed EventLink (\(eventLink.UUID.uuidString)) from Beat (\(UUID.uuidString)).", level: .info)
		_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvBeatDidRemoveEventLink(story: _story, beat: self, link: eventLink)}
	}
}

extension NVBeat: NVPathable {
	func localPath() -> String {
		return Label.isEmpty ? "Unnamed" : Label
	}
	
	func localObject() -> Any {
		return self
	}
	
	func parentPathable() -> NVPathable? {
		return Parent
	}
}

extension NVBeat: Equatable {
	static func == (lhs: NVBeat, rhs: NVBeat) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
