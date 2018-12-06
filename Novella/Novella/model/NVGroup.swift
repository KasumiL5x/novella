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
	var Label: String {
		didSet {
			NVLog.log("Group (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Delegates.forEach{$0.nvGroupLabelDidChange(story: _story, group: self)}
		}
	}
	var PreCondition: NVCondition
	var EntryFunction: NVFunction
	var ExitFunction: NVFunction
	var Entry: NVBeat? {
		didSet {
			// must be part of the group
			if let entry = Entry, !contains(beat: entry) {
				Entry = nil
				NVLog.log("Tried to set Group (\(UUID.uuidString)) Entry to a non-included Beat.", level: .warning)
			} else {
				NVLog.log("Group (\(UUID.uuidString)) Entry changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Entry?.UUID.uuidString ?? "nil")).", level: .info)
			}
			_story.Delegates.forEach{$0.nvGroupEntryDidChange(story: _story, group: self)}
		}
	}
	private(set) var Beats: [NVBeat]
	private(set) var BeatLinks: [NVBeatLink]
	private(set) var Groups: [NVGroup]
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = ""
		self.PreCondition = NVCondition(story: story)
		self.EntryFunction = NVFunction(story: story)
		self.ExitFunction = NVFunction(story: story)
		self.Entry = nil
		self.Beats = []
		self.BeatLinks = []
		self.Groups = []
	}
	
	func contains(beat: NVBeat) -> Bool {
		return Beats.contains(beat)
	}
	func add(beat: NVBeat) {
		if contains(beat: beat) {
			NVLog.log("Tried to add Beat (\(beat.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Beats.append(beat)
		
		NVLog.log("Added Beat (\(beat.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidAddBeat(story: _story, group: self, beat: beat)}
	}
	func remove(beat: NVBeat) {
		guard let idx = Beats.index(of: beat) else {
			NVLog.log("Tried to remove Beat (\(beat.UUID)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Beats.remove(at: idx)
		NVLog.log("Removed Beat (\(beat.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidRemoveBeat(story: _story, group: self, beat: beat)}

		if Entry == beat {
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
		
		NVLog.log("Added Group (\(group.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidAddGroup(story: _story, group: self, child: group)}
	}
	func remove(group: NVGroup) {
		guard let idx = Groups.index(of: group) else {
			NVLog.log("Tried to remove Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Groups.remove(at: idx)
		
		NVLog.log("Removed Group (\(group.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidRemoveGroup(story: _story, group: self, child: group)}
	}
	
	func contains(beatLink: NVBeatLink) -> Bool {
		return BeatLinks.contains(beatLink)
	}
	func add(beatLink: NVBeatLink) {
		if contains(beatLink: beatLink) {
			NVLog.log("Tried to add BeatLink (\(beatLink.UUID.uuidString)) to Group (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		BeatLinks.append(beatLink)
		
		NVLog.log("Added BeatLink (\(beatLink.UUID.uuidString)) to Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidAddBeatLink(story: _story, group: self, link: beatLink)}
	}
	func remove(beatLink: NVBeatLink) {
		guard let idx = BeatLinks.index(of: beatLink) else {
			NVLog.log("Tried to remove BeatLink (\(beatLink.UUID.uuidString)) from Group (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		BeatLinks.remove(at: idx)
		
		NVLog.log("Removed BeatLink (\(beatLink.UUID.uuidString)) from Group (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvGroupDidRemoveBeatLink(story: _story, group: self, link: beatLink)}
	}
}

extension NVGroup: Equatable {
	static func == (lhs: NVGroup, rhs: NVGroup) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
