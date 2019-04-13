//
//  NVEvent.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVEvent: NVIdentifiable, NVLinkable {
	func canBecomeOrigin() -> Bool {
		return true
	}
	
	var UUID: NSUUID
	private let _story: NVStory
	var Parent: NVSequence? // warning: no friend class support so has to be public
	
	var Label: String {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvEventLabelDidChange(story: _story, event: self)}
		}
	}
	//
	var Parallel: Bool {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Parallel changed (\(oldValue) -> \(Parallel)).", level: .info)
			_story.Observers.forEach{$0.nvEventParallelDidChange(story: _story, event: self)}
		}
	}
	var Topmost: Bool {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Topmost changed (\(oldValue) -> \(Topmost)).", level: .info)
			_story.Observers.forEach{$0.nvEventTopmostDidChange(story: _story, event: self)}
		}
	}
	var MaxActivations: Int {
		didSet {
			if MaxActivations < 0 {
				MaxActivations = oldValue
				NVLog.log("Tried to set Event (\(UUID.uuidString)) MaxActivations but the value was negative.", level: .warning)
			} else {
				NVLog.log("Event (\(UUID.uuidString)) MaxActivations changed (\(oldValue) -> \(MaxActivations)).", level: .info)
				_story.Observers.forEach{$0.nvEventMaxActivationsDidChange(story: _story, event: self)}
			}
		}
	}
	var KeepAlive: Bool {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) KeepAlive changed (\(oldValue) -> \(KeepAlive)).", level: .info)
			_story.Observers.forEach{$0.nvEventKeepAliveDidChange(story: _story, event: self)}
		}
	}
	//
	var PreCondition: NVCondition? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Condition changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(PreCondition?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventConditionDidChange(story: _story, event: self)}
		}
	}
	var EntryFunction: NVFunction? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) entry Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(EntryFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventEntryFunctionDidChange(story: _story, event: self)}
		}
	}
	var DoFunction: NVFunction? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) do Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(DoFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventDoFunctionDidChange(story: _story, event: self)}
		}
	}
	var ExitFunction: NVFunction? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) exit Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ExitFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventExitFunctionDidChange(story: _story, event: self)}
		}
	}
	var Instigators: NVSelector? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Instigators changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Instigators?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventInstigatorsDidChange(story: _story, event: self)}
		}
	}
	var Targets: NVSelector? {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Targets changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(Instigators?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvEventTargetsDidChange(story: _story, event: self)}
		}
	}
	var Attributes: NSMutableDictionary {
		didSet {
			NVLog.log("Event (\(UUID.uuidString)) Attributes changed.", level: .info)
			_story.Observers.forEach{$0.nvEventAttributesDidChange(story: _story, event: self)}
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
		self.DoFunction = nil
		self.ExitFunction = nil
		self.Instigators = nil
		self.Targets = nil
		self.Attributes = [:]
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
