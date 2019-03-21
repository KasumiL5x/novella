//
//  NVGroup.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVGroup: NVIdentifiable {
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
	var PreCondition: NVCondition?
	var EntryFunction: NVFunction?
	var ExitFunction: NVFunction?
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
	private(set) var SequenceLinks: [NVSequenceLink]
	private(set) var Groups: [NVGroup]
	
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
		self.SequenceLinks = []
		self.Groups = []
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
		guard let idx = Sequences.index(of: sequence) else {
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
		guard let idx = Groups.index(of: group) else {
			NVLog.log("Tried to remove Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Groups.remove(at: idx)
		group.Parent = nil
		
		NVLog.log("Removed Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveGroup(story: _story, group: self, child: group)}
	}
	
	func contains(sequenceLink: NVSequenceLink) -> Bool {
		return SequenceLinks.contains(sequenceLink)
	}
	func add(sequenceLink: NVSequenceLink) {
		if contains(sequenceLink: sequenceLink) {
			NVLog.log("Tried to add SequenceLink (\(sequenceLink.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		SequenceLinks.append(sequenceLink)
		
		NVLog.log("Added SequenceLink (\(sequenceLink.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidAddSequenceLink(story: _story, group: self, link: sequenceLink)}
	}
	func remove(sequenceLink: NVSequenceLink) {
		guard let idx = SequenceLinks.index(of: sequenceLink) else {
			NVLog.log("Tried to remove SequenceLink (\(sequenceLink.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		SequenceLinks.remove(at: idx)
		
		NVLog.log("Removed SequenceLink (\(sequenceLink.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Observers.forEach{$0.nvGroupDidRemoveSequenceLink(story: _story, group: self, link: sequenceLink)}
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
