//
//  NVStory.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVStory {
	private var _observers = [ObjectIdentifier: Observation]()
	public var Observers: [NVStoryObserver] {
		get{
			return _observers.compactMap{ $0.value.observer }
		}
	}
	
	private var _identifiables: [NVIdentifiable]
	private(set) var MainGroup: NVGroup! // see init for ! usage
	
	var Groups: [NVGroup] {
		get{ return _identifiables.filter{$0 is NVGroup} as! [NVGroup] }
	}
	var Sequences: [NVSequence] {
		get{ return _identifiables.filter{$0 is NVSequence} as! [NVSequence] }
	}
	var Discoverables: [NVDiscoverableSequence] {
		get{ return _identifiables.filter{$0 is NVDiscoverableSequence} as! [NVDiscoverableSequence] }
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
	var Selectors: [NVSelector] {
		get{ return _identifiables.filter{$0 is NVSelector} as! [NVSelector] }
	}
	
	init() {
		self._identifiables = []
		self.MainGroup = nil // cannot use self here so nil it first
		
		self.MainGroup = NVGroup(uuid: NSUUID(), story: self)
		self.MainGroup.Label = "Main Group"
	}
	
	func add(observer: NVStoryObserver) {
		let id = ObjectIdentifier(observer)
		_observers[id] = Observation(observer: observer)
	}
	
	func remove(observer: NVStoryObserver) {
		let id = ObjectIdentifier(observer)
		_observers.removeValue(forKey: id)
	}
	
	func find(uuid: String) -> NVIdentifiable? {
		return _identifiables.first(where: {$0.UUID.uuidString == uuid})
	}
	
	// CREATION
	func makeGroup(uuid: NSUUID?=nil) -> NVGroup {
		let group = NVGroup(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(group)
		
		NVLog.log("Created Group (\(group.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeGroup(story: self, group: group)}
		return group
	}
	func makeSequence(uuid: NSUUID?=nil) -> NVSequence {
		let sequence = NVSequence(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(sequence)
		
		NVLog.log("Created Sequence (\(sequence.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeSequence(story: self, sequence: sequence)}
		return sequence
	}
	func makeDNSequence(uuid: NSUUID?=nil) -> NVDiscoverableSequence {
		let sequence = NVDiscoverableSequence(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(sequence)
		
		NVLog.log("Created DiscoverableSequence (\(sequence.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeSequence(story: self, sequence: sequence)}
		return sequence
	}
	func makeEvent(uuid: NSUUID?=nil) -> NVEvent {
		let event = NVEvent(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(event)
		
		NVLog.log("Created Event (\(event.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeEvent(story: self, event: event)}
		return event
	}
	func makeEntity(uuid: NSUUID?=nil) -> NVEntity {
		let entity = NVEntity(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(entity)
		
		NVLog.log("Created Entity (\(entity.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeEntity(story: self, entity: entity)}
		return entity
	}
	func makeSequenceLink(uuid: NSUUID?=nil, origin: NVSequence, dest: NVSequence?) -> NVSequenceLink {
		let link = NVSequenceLink(uuid: uuid ?? NSUUID(), story: self, origin: origin, destination: dest)
		_identifiables.append(link)
		
		NVLog.log("Created SequenceLink (\(link.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeSequenceLink(story: self, link: link)}
		return link
	}
	func makeEventLink(uuid: NSUUID?=nil, origin: NVEvent, dest: NVEvent?) -> NVEventLink {
		let link = NVEventLink(uuid: uuid ?? NSUUID(), story: self, origin: origin, destination: dest)
		_identifiables.append(link)
		
		NVLog.log("Created EventLink (\(link.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeEventLink(story: self, link: link)}
		return link
	}
	func makeVariable(uuid: NSUUID?=nil) -> NVVariable {
		let variable = NVVariable(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(variable)
		
		NVLog.log("Created Variable (\(variable.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeVariable(story: self, variable: variable)}
		return variable
	}
	func makeFunction(uuid: NSUUID?=nil) -> NVFunction {
		let function = NVFunction(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(function)
		
		NVLog.log("Created Function (\(function.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeFunction(story: self, function: function)}
		return function
	}
	func makeCondition(uuid: NSUUID?=nil) -> NVCondition {
		let condition = NVCondition(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(condition)
		
		NVLog.log("Created Condition (\(condition.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeCondition(story: self, condition: condition)}
		return condition
	}
	func makeSelector(uuid: NSUUID?=nil) -> NVSelector {
		let selector = NVSelector(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(selector)
		
		NVLog.log("Created Selector (\(selector.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeSelector(story: self, selector: selector)}
		return selector
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
		Observers.forEach{$0.nvStoryDidDeleteGroup(story: self, group: group)}
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
		Observers.forEach{$0.nvStoryDidDeleteSequence(story: self, sequence: sequence)}
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
		Observers.forEach{$0.nvStoryDidDeleteEvent(story: self, event: event)}
	}
	func delete(entity: NVEntity) {
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == entity.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Entity (\(entity.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteEntity(story: self, entity: entity)}
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
		Observers.forEach{$0.nvStoryDidDeleteSequenceLink(story: self, link: sequenceLink)}
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
		Observers.forEach{$0.nvStoryDidDeleteEventLink(story: self, link: eventLink)}
	}
	func delete(variable: NVVariable) {
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == variable.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Variable (\(variable.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteVariable(story: self, variable: variable)}
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
		Observers.forEach{$0.nvStoryDidDeleteFunction(story: self, function: function)}
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
		Observers.forEach{$0.nvStoryDidDeleteCondition(story: self, condition: condition)}
	}
	func delete(selector: NVSelector) {
		// remove from all events
		Events.forEach{ (event) in
			if event.Instigators == selector {
				event.Instigators = nil
			}
			if event.Targets == selector {
				event.Targets = nil
			}
		}
		
		// remove frmo story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == selector.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Selector (\(selector.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteSelector(story: self, selector: selector)}
	}
}

private extension NVStory {
	struct Observation {
		weak var observer: NVStoryObserver?
	}
}
