//
//  NVHub.swift
//  novella
//
//  Created by Daniel Green on 14/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

class NVHub: NVIdentifiable, NVLinkable {
	func canBecomeOrigin() -> Bool {
		return true
	}
	
	var UUID: NSUUID
	private let _story: NVStory
	
	var Label: String {
		didSet {
			NVLog.log("Hub (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvHubLabelDidChange(story: _story, hub: self)}
		}
	}
	
	var Condition: NVCondition? {
		didSet {
			NVLog.log("Hub (\(UUID.uuidString)) Condition changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Condition?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvHubConditionDidChange(story: _story, hub: self)}
		}
	}
	
	var EntryFunction: NVFunction? {
		didSet {
			NVLog.log("Hub (\(UUID.uuidString)) Entry Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(EntryFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvHubEntryFunctionDidChange(story: _story, hub: self)}
		}
	}
	
	var ReturnFunction: NVFunction? {
		didSet {
			NVLog.log("Hub (\(UUID.uuidString)) Return Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ReturnFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvHubReturnFunctionDidChange(story: _story, hub: self)}
		}
	}
	
	var ExitFunction: NVFunction? {
		didSet {
			NVLog.log("Hub (\(UUID.uuidString)) Exit Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ExitFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvHubExitFunctionDidChange(story: _story, hub: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = ""
		self.Condition = nil
		self.EntryFunction = nil
		self.ReturnFunction = nil
		self.ExitFunction = nil
	}
}

extension NVHub: Equatable {
	static func == (lhs: NVHub, rhs: NVHub) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
