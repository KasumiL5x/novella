//
//  NVSequence.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVSequence: NVIdentifiable, NVLinkable {
	func canBecomeOrigin() -> Bool {
		return true
	}
	
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
	var PreCondition: NVCondition? {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) Condition changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(PreCondition?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvSequenceConditionDidChange(story: _story, sequence: self)}
		}
	}
	var EntryFunction: NVFunction? {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) entry Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(EntryFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvSequenceEntryFunctionDidChange(story: _story, sequence: self)}
		}
	}
	var ExitFunction: NVFunction? {
		didSet {
			NVLog.log("Sequence (\(UUID.uuidString)) exit Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ExitFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvSequenceExitFunctionDidChange(story: _story, sequence: self)}
		}
	}
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
	private(set) var Links: [NVLink]
	private(set) var Hubs: [NVHub]
	private(set) var Returns: [NVReturn]
	var Attributes: NSMutableDictionary {
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
		self.Links = []
		self.Hubs = []
		self.Returns = []
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
		guard let idx = Events.firstIndex(of: event) else {
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
	
	func contains(link: NVLink) -> Bool {
		return Links.contains(link)
	}
	func add(link: NVLink) {
		if contains(link: link) {
			NVLog.log("Tried to add Link (\(link.UUID.uuidString)) to Sequence (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Links.append(link)
		NVLog.log("Added Link (\(link.UUID.uuidString)) to Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidAddLink(story: _story, sequence: self, link: link)}
	}
	func remove(link: NVLink) {
		guard let idx = Links.firstIndex(of: link) else {
			NVLog.log("Tried to remove Link (\(link.UUID.uuidString)) from Sequence (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Links.remove(at: idx)
		NVLog.log("Removed Link (\(link.UUID.uuidString)) from Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidRemoveLink(story: _story, sequence: self, link: link)}
	}
	
	// hubs
	func contains(hub: NVHub) -> Bool {
		return Hubs.contains(hub)
	}
	func add(hub: NVHub) {
		if contains(hub: hub) {
			NVLog.log("Tried to add Hub (\(hub.UUID.uuidString)) to Sequence (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Hubs.append(hub)
		
		NVLog.log("Added Hub (\(hub.UUID.uuidString)) to Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidAddHub(story: _story, sequence: self, hub: hub)}
	}
	func remove(hub: NVHub) {
		guard let idx = Hubs.firstIndex(of: hub) else {
			NVLog.log("Tried to remove Hub (\(hub.UUID.uuidString)) from Sequence (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Hubs.remove(at: idx)
		
		NVLog.log("Removed Hub (\(hub.UUID.uuidString)) from Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidRemoveHub(story: _story, sequence: self, hub: hub)}
	}
	
	// returns
	func contains(rtrn: NVReturn) -> Bool {
		return Returns.contains(rtrn)
	}
	func add(rtrn: NVReturn) {
		if contains(rtrn: rtrn) {
			NVLog.log("Tried to add Return (\(rtrn.UUID.uuidString)) to Sequence (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Returns.append(rtrn)
		
		NVLog.log("Added Return (\(rtrn.UUID.uuidString)) to Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidAddReturn(story: _story, sequence: self, rtrn: rtrn)}
	}
	func remove(rtrn: NVReturn) {
		guard let idx = Returns.firstIndex(of: rtrn) else {
			NVLog.log("Tried to remove Return (\(rtrn.UUID.uuidString)) from Sequence (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Returns.remove(at: idx)
		
		NVLog.log("Removed Return (\(rtrn.UUID.uuidString)) from Sequence (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvSequenceDidRemoveReturn(story: _story, sequence: self, rtrn: rtrn)}
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
