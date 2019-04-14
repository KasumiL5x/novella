//
//  NVGroup.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVGroup: NVIdentifiable, NVLinkable {
	func canBecomeOrigin() -> Bool {
		return true
	}
	
	var UUID: NSUUID
	private let _story: NVStory
	var Parent: NVGroup? // warning: no friend class support so has to be public
	
	var Label: String {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvGroupLabelDidChange(story: _story, group: self)}
		}
	}
	//
	var Topmost: Bool {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) Topmost changed (\(oldValue) -> \(Topmost)).", level: .info)
			_story.Observers.forEach{$0.nvGroupTopmostDidChange(story: _story, group: self)}
		}
	}
	var MaxActivations: Int {
		didSet {
			if MaxActivations < 0 {
				MaxActivations = oldValue
				NVLog.log("Tried to set Group (\(UUID.uuidString)) MaxActivations but the value was negative.", level: .warning)
			} else {
				NVLog.log("Group (\(UUID.uuidString)) MaxActivations changed (\(oldValue) -> \(MaxActivations)).", level: .info)
				_story.Observers.forEach{$0.nvGroupMaxActivationsDidChange(story: _story, group: self)}
			}
		}
	}
	var KeepAlive: Bool {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) KeepAlive changed (\(oldValue) -> \(KeepAlive)).", level: .info)
			_story.Observers.forEach{$0.nvGroupKeepAliveDidChange(story: _story, group: self)}
		}
	}
	//
	var PreCondition: NVCondition? {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) Condition changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(PreCondition?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvGroupConditionDidChange(story: _story, group: self)}
		}
	}
	var EntryFunction: NVFunction? {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) entry Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(EntryFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvGroupEntryFunctionDidChange(story: _story, group: self)}
		}
	}
	var ExitFunction: NVFunction? {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) exit Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ExitFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvGroupExitFunctionDidChange(story: _story, group: self)}
		}
	}
	var Entry: NVSequence? {
		didSet {
			// must be part of the group
			if let entry = Entry, !contains(sequence: entry) {
				Entry = nil
				NVLog.log("Tried to set Group (\(UUID.uuidString)) Entry to a non-included Sequence.", level: .warning)
			} else {
				NVLog.log("Group (\(UUID.uuidString)) Entry changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Entry?.UUID.uuidString ?? "nil")).", level: .info)
			}
			_story.Observers.forEach{$0.nvGroupEntryDidChange(story: _story, group: self, oldEntry: oldValue, newEntry: Entry)}
		}
	}
	private(set) var Sequences: [NVSequence]
	private(set) var Links: [NVLink]
	private(set) var Groups: [NVGroup]
	private(set) var Hubs: [NVHub]
	private(set) var Returns: [NVReturn]
	var Attributes: NSMutableDictionary {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) Attributes changed.", level: .info)
			_story.Observers.forEach{$0.nvGroupAttributesDidChange(story: _story, group: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Parent = nil
		self.Label = ""
		self.Topmost = false
		self.MaxActivations = 0
		self.KeepAlive = false
		self.PreCondition = nil
		self.EntryFunction = nil
		self.ExitFunction = nil
		self.Entry = nil
		self.Sequences = []
		self.Links = []
		self.Groups = []
		self.Hubs = []
		self.Returns = []
		self.Attributes = [:]
	}
	
	func contains(sequence: NVSequence) -> Bool {
		return Sequences.contains(sequence)
	}
	func add(sequence: NVSequence) {
		if contains(sequence: sequence) {
			NVLog.log("Tried to add Sequence (\(sequence.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Sequences.append(sequence)
		sequence.Parent = self
		
		NVLog.log("Added Sequence (\(sequence.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddSequence(story: _story, group: self, sequence: sequence)}
	}
	func remove(sequence: NVSequence) {
		guard let idx = Sequences.firstIndex(of: sequence) else {
			NVLog.log("Tried to remove Sequence (\(sequence.UUID)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Sequences.remove(at: idx)
		sequence.Parent = nil
		
		NVLog.log("Removed Sequence (\(sequence.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveSequence(story: _story, group: self, sequence: sequence)}
		
		if Entry == sequence {
			Entry = nil
		}
	}
	
	func contains(group: NVGroup) -> Bool {
		return Groups.contains(group)
	}
	func add(group: NVGroup) {
		if group == self {
			NVLog.log("Tried to add Group (\(UUID.uuidString)) to self.", level: .warning)
			return
		}
		
		if contains(group: group) {
			NVLog.log("Tried to add Group (\(group.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Groups.append(group)
		group.Parent = self
		
		NVLog.log("Added Group (\(group.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddGroup(story: _story, group: self, child: group)}
	}
	func remove(group: NVGroup) {
		guard let idx = Groups.firstIndex(of: group) else {
			NVLog.log("Tried to remove Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Groups.remove(at: idx)
		group.Parent = nil
		
		NVLog.log("Removed Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveGroup(story: _story, group: self, child: group)}
	}
	
	func contains(link: NVLink) -> Bool {
		return Links.contains(link)
	}
	func add(link: NVLink) {
		if contains(link: link) {
			NVLog.log("Tried to add Link (\(link.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Links.append(link)
		
		NVLog.log("Added Link (\(link.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddLink(story: _story, group: self, link: link)}
	}
	func remove(link: NVLink) {
		guard let idx = Links.firstIndex(of: link) else {
			NVLog.log("Tried to remove Link (\(link.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Links.remove(at: idx)
		
		NVLog.log("Removed Link (\(link.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveLink(story: _story, group: self, link: link)}
	}
	
	// hubs
	func contains(hub: NVHub) -> Bool {
		return Hubs.contains(hub)
	}
	func add(hub: NVHub) {
		if contains(hub: hub) {
			NVLog.log("Tried to add Hub (\(hub.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Hubs.append(hub)
		
		NVLog.log("Added Hub (\(hub.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddHub(story: _story, group: self, hub: hub)}
	}
	func remove(hub: NVHub) {
		guard let idx = Hubs.firstIndex(of: hub) else {
			NVLog.log("Tried to remove Hub (\(hub.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Hubs.remove(at: idx)
		
		NVLog.log("Removed Hub (\(hub.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveHub(story: _story, group: self, hub: hub)}
	}
	
	// returns
	func contains(rtrn: NVReturn) -> Bool {
		return Returns.contains(rtrn)
	}
	func add(rtrn: NVReturn) {
		if contains(rtrn: rtrn) {
			NVLog.log("Tried to add Return (\(rtrn.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Returns.append(rtrn)
		
		NVLog.log("Added Return (\(rtrn.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddReturn(story: _story, group: self, rtrn: rtrn)}
	}
	func remove(rtrn: NVReturn) {
		guard let idx = Returns.firstIndex(of: rtrn) else {
			NVLog.log("Tried to remove Return (\(rtrn.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Returns.remove(at: idx)
		
		NVLog.log("Removed Return (\(rtrn.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveReturn(story: _story, group: self, rtrn: rtrn)}
	}
}

extension NVGroup: NVPathable {
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

extension NVGroup: Equatable {
	static func == (lhs: NVGroup, rhs: NVGroup) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
