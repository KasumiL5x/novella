//
//  NVStory.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import JavaScriptCore

class NVStory {
	// Delegates are stored as a generic AnyObject but are actually NVStoryDelegate.  This is because to have weak
	// references to protocols, you must use a load of hacky code, or NSHashTable/Set. However, they usually require
	// @objc for protocols, which means that all functions in the protocol need to derive from NSObject. This is shit.
	// However, it seems you can ADD and then CAST the types. As long as I abstract the adding, I can guarantee the type.
	private(set) var Delegates = NSHashTable<AnyObject>()
	
	private var _identifiables: [NVIdentifiable]
	private(set) var MainGroup: NVGroup! // see init for ! usage
	private(set) var JVM: JSContext
	
	var Groups: [NVGroup] {
		get{ return _identifiables.filter{$0 is NVGroup} as! [NVGroup] }
	}
	var Sequences: [NVSequence] {
		get{ return _identifiables.filter{$0 is NVSequence} as! [NVSequence] }
	}
	var Events: [NVEvent] {
		get{ return _identifiables.filter{$0 is NVEvent} as! [NVEvent] }
	}
	var Entities: [NVEntity] {
		get{ return _identifiables.filter{$0 is NVEntity} as! [NVEntity] }
	}
	var SequenceLinks: [NVSequenceLink] {
		get{ return _identifiables.filter{$0 is NVSequenceLink} as! [NVSequenceLink] }
	}
	var EventLinks: [NVEventLink] {
		get{ return _identifiables.filter{$0 is NVEventLink} as! [NVEventLink] }
	}
	var Variables: [NVVariable] {
		get{ return _identifiables.filter{$0 is NVVariable} as! [NVVariable] }
	}
	var Functions: [NVFunction] {
		get{ return _identifiables.filter{$0 is NVFunction} as! [NVFunction] }
	}
	var Conditions: [NVCondition] {
		get{ return _identifiables.filter{$0 is NVCondition} as! [NVCondition] }
	}
	
	init() {
		self._identifiables = []
		self.MainGroup = nil // cannot use self here so nil it first
		self.JVM = JSContext()
		self.setupJS()
		
		self.MainGroup = NVGroup(uuid: NSUUID(), story: self)
		self.MainGroup.Label = "Main Group"
	}
	
	private func setupJS() {
		JVM.exceptionHandler = { (ctx, ex) in
			if let ex = ex {
				NVLog.log("JS Error: \(ex.toString() ?? "Invalid Error.")", level: .error)
			}
		}
		
		// nvprint
		let js_nvprint: @convention(block) (String) -> Void = { msg in
			NVLog.log("\nJS: \(msg)", level: .info)
		}
		JVM.setObject(js_nvprint, forKeyedSubscript: "nvprint" as (NSCopying & NSObjectProtocol))
		
		// getbool
		let js_getbool: @convention(block) (String) -> Any? = { [weak self](name) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				NVLog.log("JS get bool: \(name). Found and returning value: \(variable.Value.Raw.asBool)", level: .debug)
				return variable.Value.Raw.asBool
			}
			NVLog.log("JS get bool: \(name). Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getbool, forKeyedSubscript: "getbool" as (NSCopying & NSObjectProtocol))
		
		// getint
		let js_getint: @convention(block) (String) -> Any? = { [weak self](name) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				NVLog.log("JS get int: \(name). Found and returning value: \(variable.Value.Raw.asInt)", level: .debug)
				return variable.Value.Raw.asInt
			}
			NVLog.log("JS get int: \(name). Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getint, forKeyedSubscript: "getint" as (NSCopying & NSObjectProtocol))
		
		// getdub
		let js_getdub: @convention(block) (String) -> Any? = { [weak self](name) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				NVLog.log("JS get dub: \(name). Found and returning value: \(variable.Value.Raw.asDouble)", level: .debug)
				return variable.Value.Raw.asDouble
			}
			NVLog.log("JS get dub: \(name). Not found; returning nil.", level: .debug)
			return nil
		}
		JVM.setObject(js_getdub, forKeyedSubscript: "getdub" as (NSCopying & NSObjectProtocol))
		
		// setbool
		let js_setbool: @convention(block) (String, Bool) -> Void = { [weak self](name, value) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				variable.set(value: NVValue(.boolean(value)))
				NVLog.log("JS set bool: \(name). Found and set to: \(value).", level: .debug)
			} else {
				NVLog.log("JS set bool: \(name). Not found; ignoring.", level: .debug)
			}
		}
		JVM.setObject(js_setbool, forKeyedSubscript: "setbool" as (NSCopying & NSObjectProtocol))
		
		// setint
		let js_setint: @convention(block) (String, Int32) -> Void = { [weak self](name, value) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				variable.set(value: NVValue(.integer(value)))
				NVLog.log("JS set int: \(name). Found and set to: \(value).", level: .debug)
			} else {
				NVLog.log("JS set int: \(name). Not found; ignoring.", level: .debug)
			}
		}
		JVM.setObject(js_setint, forKeyedSubscript: "setint" as (NSCopying & NSObjectProtocol))
		
		// setdub
		let js_setdub: @convention(block) (String, Double) -> Void = { [weak self](name, value) in
			if let variable = self!.Variables.first(where: {$0.Name == name}) {
				variable.set(value: NVValue(.double(value)))
				NVLog.log("JS set dub: \(name). Found and set to: \(value).", level: .debug)
			} else {
				NVLog.log("JS set dub: \(name). Not found; ignoring.", level: .debug)
			}
		}
		JVM.setObject(js_setdub, forKeyedSubscript: "setdub" as (NSCopying & NSObjectProtocol))
	}
	
	func addDelegate(_ delegate: NVStoryDelegate) {
		Delegates.add(delegate)
	}
	func removeDelegate(_ delegate: NVStoryDelegate) {
		Delegates.remove(delegate)
	}
	
	func find(uuid: String) -> NVIdentifiable? {
		return _identifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	// CREATION
	func makeGroup(uuid: NSUUID?=nil) -> NVGroup {
		let group = NVGroup(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(group)
		
		NVLog.log("Created Group (\(group.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeGroup(story: self, group: group)}
		return group
	}
	func makeSequence(uuid: NSUUID?=nil) -> NVSequence {
		let sequence = NVSequence(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(sequence)
		
		NVLog.log("Created Sequence (\(sequence.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeSequence(story: self, sequence: sequence)}
		return sequence
	}
	func makeDNSequence(uuid: NSUUID?=nil) -> NVDiscoverableSequence {
		let sequence = NVDiscoverableSequence(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(sequence)
		
		NVLog.log("Created DiscoverableSequence (\(sequence.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeSequence(story: self, sequence: sequence)}
		return sequence
	}
	func makeEvent(uuid: NSUUID?=nil) -> NVEvent {
		let event = NVEvent(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(event)
		
		NVLog.log("Created Event (\(event.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeEvent(story: self, event: event)}
		return event
	}
	func makeEntity(uuid: NSUUID?=nil) -> NVEntity {
		let entity = NVEntity(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(entity)
		
		NVLog.log("Created Entity (\(entity.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeEntity(story: self, entity: entity)}
		return entity
	}
	func makeSequenceLink(uuid: NSUUID?=nil, origin: NVSequence, dest: NVSequence?) -> NVSequenceLink {
		let link = NVSequenceLink(uuid: uuid ?? NSUUID(), story: self, origin: origin, destination: dest)
		_identifiables.append(link)
		
		NVLog.log("Created SequenceLink (\(link.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeSequenceLink(story: self, link: link)}
		return link
	}
	func makeEventLink(uuid: NSUUID?=nil, origin: NVEvent, dest: NVEvent?) -> NVEventLink {
		let link = NVEventLink(uuid: uuid ?? NSUUID(), story: self, origin: origin, destination: dest)
		_identifiables.append(link)
		
		NVLog.log("Created EventLink (\(link.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeEventLink(story: self, link: link)}
		return link
	}
	func makeVariable(uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(variable)
		
		NVLog.log("Created Variable (\(variable.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeVariable(story: self, variable: variable)}
		return variable
	}
	func makeFunction(uuid: NSUUID?=nil) -> NVFunction {
		let function = NVFunction(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(function)
		
		NVLog.log("Created Function (\(function.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeFunction(story: self, function: function)}
		return function
	}
	func makeCondition(uuid: NSUUID?=nil) -> NVCondition {
		let condition = NVCondition(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(condition)
		
		NVLog.log("Created Condition (\(condition.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidMakeCondition(story: self, condition: condition)}
		return condition
	}
	
	// DELETION
	func delete(group: NVGroup) {
		if group == MainGroup {
			NVLog.log("Tried to delete MainGroup.", level: .warning)
			return // cannot remove main group
		}
		
		// remove from all parent groups
		Groups.forEach { (parentGroup) in
			if parentGroup == group {
				return // don't bother with self (only returns the current iteration, like continue)
			}
			if parentGroup.contains(group: group) {
				parentGroup.remove(group: group)
			}
		}
		
		// remove all child sequences
		for (_, sequence) in group.Sequences.enumerated().reversed() {
			delete(sequence: sequence)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == group.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Group (\(group.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteGroup(story: self, group: group)}
	}
	func delete(sequence: NVSequence) {
		// remove from any links as source or destination
		for (_, link) in SequenceLinks.enumerated().reversed() {
			// nil destinations
			if link.Destination == sequence {
				link.Destination = nil
			}
			// fully remove if origin
			if link.Origin == sequence {
				delete(sequenceLink: link)
			}
		}
		
		// remove from all groups (incl. entry in the remove function)
		Groups.forEach { (group) in
			if group.contains(sequence: sequence) {
				group.remove(sequence: sequence)
			}
		}
		// same treatment for main group since it's not in the list
		if MainGroup.contains(sequence: sequence) {
			MainGroup.remove(sequence: sequence)
		}
		
		// remove all child events of the sequence too
		for (_, event) in sequence.Events.enumerated().reversed() {
			delete(event: event)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == sequence.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Sequence (\(sequence.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteSequence(story: self, sequence: sequence)}
	}
	func delete(event: NVEvent) {
		// remove from any links as source or destination
		for (_, link) in EventLinks.enumerated().reversed() {
			// nil destinations
			if link.Destination == event {
				link.Destination = nil
			}
			// fully remove if origin
			if link.Origin == event {
				delete(eventLink: link)
			}
		}
		
		// remove from all sequences (incl. entry in the remove function)
		Sequences.forEach { (sequence) in
			if sequence.contains(event: event) {
				sequence.remove(event: event)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == event.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Event (\(event.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteEvent(story: self, event: event)}
	}
	func delete(entity: NVEntity) {
		// remove from all events
		Events.forEach { (event) in
			if event.contains(participant: entity) {
				event.remove(participant: entity)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == entity.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Entity (\(entity.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteEntity(story: self, entity: entity)}
	}
	func delete(sequenceLink: NVSequenceLink) {
		// remove from all groups that contain it
		Groups.forEach { (group) in
			if group.contains(sequenceLink: sequenceLink) {
				group.remove(sequenceLink: sequenceLink)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == sequenceLink.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted SequenceLink (\(sequenceLink.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteSequenceLink(story: self, link: sequenceLink)}
	}
	func delete(eventLink: NVEventLink) {
		// remove from all sequences that contain it
		Sequences.forEach { (sequence) in
			if sequence.contains(eventLink: eventLink) {
				sequence.remove(eventLink: eventLink)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == eventLink.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted EventLink (\(eventLink.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteEventLink(story: self, link: eventLink)}
	}
	func delete(variable: NVVariable) {
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == variable.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Variable (\(variable.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteVariable(story: self, variable: variable)}
	}
	func delete(function: NVFunction) {
		// remove from sequences
		Sequences.forEach { (sequence) in
			if sequence.EntryFunction == function {
				sequence.EntryFunction = nil
			}
			if sequence.ExitFunction == function {
				sequence.ExitFunction = nil
			}
		}
		
		// remove from events
		Events.forEach { (event) in
			if event.EntryFunction == function {
				event.EntryFunction = nil
			}
			if event.ExitFunction == function {
				event.ExitFunction = nil
			}
		}
		
		// remove from groups
		Groups.forEach { (group) in
			if group.EntryFunction == function {
				group.EntryFunction = nil
			}
			if group.ExitFunction == function {
				group.ExitFunction = nil
			}
		}
		
		// remove from links
		SequenceLinks.forEach { (link) in
			if link.Function == function {
				link.Function = nil
			}
		}
		EventLinks.forEach { (link) in
			if link.Function == function {
				link.Function = nil
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == function.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Function (\(function.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteFunction(story: self, function: function)}
	}
	func delete(condition: NVCondition) {
		// remove from sequences
		Sequences.forEach { (sequence) in
			if sequence.PreCondition == condition {
				sequence.PreCondition = nil
			}
		}
		
		// remove from events
		Events.forEach { (event) in
			if event.PreCondition == condition {
				event.PreCondition = nil
			}
		}
		
		// remove from groups
		Groups.forEach { (group) in
			if group.PreCondition == condition {
				group.PreCondition = nil
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == condition.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Condition (\(condition.UUID.uuidString)).", level: .info)
		Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvStoryDidDeleteCondition(story: self, condition: condition)}
	}
}
