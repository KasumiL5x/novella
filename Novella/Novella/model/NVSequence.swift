//
//  NVSequence.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVSequence: NVIdentifiable {
	var UUID: NSUUID
	let _story: NVStory
	var Parent: NVGroup? // warning: no friend class support so has to be public
	
	var Label: String {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvSequenceLabelDidChange(story: _story, sequence: self)}
		}
	}
	//
	var Parallel: Bool {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) Parallel changed (\(oldValue) -> \(Parallel)).", level: .info)
			_story.Observers.forEach{$0.nvSequenceParallelDidChange(story: _story, sequence: self)}
		}
	}
	var Topmost: Bool {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) Topmost changed (\(oldValue) -> \(Topmost)).", level: .info)
			_story.Observers.forEach{$0.nvSequenceTopmostDidChange(story: _story, sequence: self)}
		}
	}
	var MaxActivations: Int {
		didSet {
			if MaxActivations < 0 {
				MaxActivations = oldValue
				NVLog.log("Tried to set Sequence (\(UUID.uuidString)) MaxActivations but the value was negative.", level: .warning)
			} else {
				NVLog.log("Sequence (\(UUID.uuidString)) MaxActivations changed (\(oldValue) -> \(MaxActivations)).", level: .info)
				_story.Observers.forEach{$0.nvSequenceMaxActivationsDidChange(story: _story, sequence: self)}
			}
		}
	}
	var KeepAlive: Bool {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) KeepAlive changed (\(oldValue) -> \(KeepAlive)).", level: .info)
			_story.Observers.forEach{$0.nvSequenceKeepAliveDidChange(story: _story, sequence: self)}
		}
	}
	//
	var PreCondition: NVCondition?
	var EntryFunction: NVFunction?
	var ExitFunction: NVFunction?
	var Entry: NVEvent? {
		didSet {
			// must be part of the sequence
			if let entry = Entry, !contains(event: entry) {
				Entry = nil
				NVLog.log("Tried to set Sequence (\(UUID.uuidString)) Entry to a non-included Entry.", level: .warning)
			} else {
				NVLog.log("Sequence (\(UUID.uuidString)) Entry changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Entry?.UUID.uuidString ?? "nil")).", level: .info)
			}
			_story.Observers.forEach{$0.nvSequenceEntryDidChange(story: _story, sequence: self, oldEntry: oldValue, newEntry: Entry)}
		}
	}
	private(set) var Events: [NVEvent]
	private(set) var EventLinks: [NVEventLink]
	var Attributes: [String: NVValue] {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) Attributes changed.", level: .info)
			_story.Observers.forEach{$0.nvSequenceAttributesDidChange(story: _story, sequence: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Parent = nil
		self.Label = ""
		self.Parallel = false
		self.Topmost = false
		self.MaxActivations = 0
		self.KeepAlive = false
		self.PreCondition = nil
		self.EntryFunction = nil
		self.ExitFunction = nil
		self.Entry = nil
		self.Events = []
		self.EventLinks = []
		self.Attributes = [:]
	}
	
	func contains(event: NVEvent) -> Bool {
		return Events.contains(event)
	}
	func add(event: NVEvent) {
		if contains(event: event) {
			NVLog.log("Tried to add Event (\(event.UUID.uuidString)) to Sequence (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Events.append(event)
		event.Parent = self
		
		NVLog.log("Added Event (\(event.UUID.uuidString)) to Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidAddEvent(story: _story, sequence: self, event: event)}
	}
	func remove(event: NVEvent) {
		guard let idx = Events.index(of: event) else {
			NVLog.log("Tried to remove Event (\(event.UUID.uuidString)) from Sequence (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Events.remove(at: idx)
		event.Parent = nil
		
		NVLog.log("Removed Event (\(event.UUID.uuidString)) from Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidRemoveEvent(story: _story, sequence: self, event: event)}
		
		if Entry == event {
			Entry = nil
		}
	}
	
	func contains(eventLink: NVEventLink) -> Bool {
		return EventLinks.contains(eventLink)
	}
	func add(eventLink: NVEventLink) {
		if contains(eventLink: eventLink) {
			NVLog.log("Tried to add EventLink (\(eventLink.UUID.uuidString)) to Sequence (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		EventLinks.append(eventLink)
		NVLog.log("Added EventLink (\(eventLink.UUID.uuidString)) to Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidAddEventLink(story: _story, sequence: self, link: eventLink)}
	}
	func remove(eventLink: NVEventLink) {
		guard let idx = EventLinks.index(of: eventLink) else {
			NVLog.log("Tried to remove EventLink (\(eventLink.UUID.uuidString)) from Sequence (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		EventLinks.remove(at: idx)
		NVLog.log("Removed EventLink (\(eventLink.UUID.uuidString)) from Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidRemoveEventLink(story: _story, sequence: self, link: eventLink)}
	}
}

extension NVSequence: NVPathable {
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

extension NVSequence: Equatable {
	static func == (lhs: NVSequence, rhs: NVSequence) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
