//
//  NVEvent.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVEvent: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	var Parent: NVBeat? // warning: no friend class support so has to be public
	var Label: String {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Delegates.forEach{$0.nvEventLabelDidChange(story: _story, event: self)}
		}
	}
	var Parallel: Bool {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Parallel changed (\(oldValue) -> \(Parallel)).", level: .info)
			_story.Delegates.forEach{$0.nvEventParallelDidChange(story: _story, event: self)}
		}
	}
	var PreCondition: NVCondition
	var EntryFunction: NVFunction
	var ExitFunction: NVFunction
	private(set) var Participants: [NVEntity]
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Parent = nil
		self.Label = ""
		self.Parallel = false
		self.PreCondition = NVCondition(story: story)
		self.EntryFunction = NVFunction(story: story)
		self.ExitFunction = NVFunction(story: story)
		self.Participants = []
	}
	
	func contains(participant: NVEntity) -> Bool {
		return Participants.contains(participant)
	}
	func add(participant: NVEntity) {
		if contains(participant: participant) {
			NVLog.log("Tried to add Entity (\(participant.UUID.uuidString)) to Event (\(UUID.uuidString)) but it already exists.", level: .warning)
			return
		}
		Participants.append(participant)
		NVLog.log("Added Entity (\(participant.UUID.uuidString)) to Event (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvEventDidAddParticipant(story: _story, event: self, entity: participant)}
	}
	func remove(participant: NVEntity) {
		guard let idx = Participants.index(of: participant) else {
			NVLog.log("Tried to remove Entity (\(participant.UUID.uuidString)) from Event (\(UUID.uuidString)) but it didn't exist.", level: .warning)
			return
		}
		Participants.remove(at: idx)
		NVLog.log("Removed Entity (\(participant.UUID.uuidString)) from Event (\(UUID.uuidString)).", level: .info)
		_story.Delegates.forEach{$0.nvEventDidRemoveParticipant(story: _story, event: self, entity: participant)}
	}
}

extension NVEvent: NVPathable {
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

extension NVEvent: Equatable {
	static func == (lhs: NVEvent, rhs: NVEvent) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
