//
//  NVStory.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

let NV_DEBUG_INDENT = 2 // move this somewhere possibly

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
	var Links: [NVLink] {
		get{ return _identifiables.filter{$0 is NVLink} as! [NVLink] }
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
	var Hubs: [NVHub] {
		get{ return _identifiables.filter{$0 is NVHub} as! [NVHub] }
	}
	var Returns: [NVReturn] {
		get{ return _identifiables.filter{$0 is NVReturn} as! [NVReturn] }
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
	func makeLink(uuid: NSUUID?=nil, origin: NVLinkable, dest: NVLinkable?) -> NVLink {
		let link = NVLink(uuid: uuid ?? NSUUID(), story: self, origin: origin, destination: dest)
		_identifiables.append(link)

		NVLog.log("Created Link (\(link.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeLink(story: self, link: link)}
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
	func makeHub(uuid: NSUUID?=nil) -> NVHub {
		let hub = NVHub(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(hub)
		
		NVLog.log("Created Hub (\(hub.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeHub(story: self, hub: hub)}
		return hub
	}
	func makeReturn(uuid: NSUUID?=nil) -> NVReturn {
		let rtrn = NVReturn(uuid: uuid ?? NSUUID(), story: self)
		_identifiables.append(rtrn)
		
		NVLog.log("Created Return (\(rtrn.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidMakeReturn(story: self, rtrn: rtrn)}
		return rtrn
	}
	
	// DELETION
	func delete(group: NVGroup) {
		if group == MainGroup {
			NVLog.log("Tried to delete MainGroup.", level: .warning)
			return // cannot remove main group
		}
		
		Observers.forEach{$0.nvStoryWillDeleteGroup(story: self, group: group)}
		
		// remove from all parent groups
		Groups.forEach { (parentGroup) in
			if parentGroup == group {
				return // don't bother with self (only returns the current iteration, like continue)
			}
			if parentGroup.contains(group: group) {
				parentGroup.remove(group: group)
			}
		}
		
		// remove all child links
		for (_, link) in group.Links.enumerated().reversed() {
			delete(link: link)
		}
		
		// remove all child sequences
		for (_, sequence) in group.Sequences.enumerated().reversed() {
			delete(sequence: sequence)
		}
		
		// remove all child hubs
		for (_, hub) in group.Hubs.enumerated().reversed() {
			delete(hub: hub)
		}
		
		// remove all child returns
		for (_, rtrn) in group.Returns.enumerated().reversed() {
			delete(rtrn: rtrn)
		}
		
		// remove all child groups
		for (_, childGroup) in group.Groups.enumerated().reversed() {
			delete(group: childGroup)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == group.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Group (\(group.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteGroup(story: self, group: group)}
	}
	func delete(sequence: NVSequence) {
		Observers.forEach{$0.nvStoryWillDeleteSequence(story: self, sequence: sequence)}
		
		// remove from any links as source or destination
		for (_, link) in Links.enumerated().reversed() {
			// nil destinations
			if link.Destination?.UUID == sequence.UUID {
				link.Destination = nil
			}
			// fully remove if origin
			if link.Origin.UUID == sequence.UUID {
				delete(link: link)
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
		
		// remove child links
		for (_, link) in sequence.Links.enumerated().reversed() {
			delete(link: link)
		}
		
		// remove child hubs
		for (_, hub) in sequence.Hubs.enumerated().reversed() {
			delete(hub: hub)
		}
		
		// delete child returns
		for (_, rtrn) in sequence.Returns.enumerated().reversed() {
			delete(rtrn: rtrn)
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == sequence.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Sequence (\(sequence.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteSequence(story: self, sequence: sequence)}
	}
	func delete(event: NVEvent) {
		Observers.forEach{$0.nvStoryWillDeleteEvent(story: self, event: event)}
		
		// remove from any links as source or destination
		for (_, link) in Links.enumerated().reversed() {
			// nil destinations
			if link.Destination?.UUID == event.UUID {
				link.Destination = nil
			}
			// fully remove if origin
			if link.Origin.UUID == event.UUID {
				delete(link: link)
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
		Observers.forEach{$0.nvStoryWillDeleteEntity(story: self, entity: entity)}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == entity.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Entity (\(entity.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteEntity(story: self, entity: entity)}
	}
	func delete(link: NVLink) {
		Observers.forEach{$0.nvStoryWillDeleteLink(story: self, link: link)}
		
		// remove from all groups that contain it
		Groups.forEach { (group) in
			if group.contains(link: link) {
				group.remove(link: link)
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == link.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Link (\(link.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteLink(story: self, link: link)}
	}
	func delete(variable: NVVariable) {
		Observers.forEach{$0.nvStoryWillDeleteVariable(story: self, variable: variable)}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == variable.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Variable (\(variable.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteVariable(story: self, variable: variable)}
	}
	func delete(function: NVFunction) {
		Observers.forEach{$0.nvStoryWillDeleteFunction(story: self, function: function)}
		
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
		Links.forEach { (link) in
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
		Observers.forEach{$0.nvStoryWillDeleteCondition(story: self, condition: condition)}
		
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
		
		// remove from links
		Links.forEach { (link) in
			if link.Condition == condition {
				link.Condition = nil
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
		Observers.forEach{$0.nvStoryWillDeleteSelector(story: self, selector: selector)}
		
		// remove from all events
		Events.forEach{ (event) in
			if event.Instigators == selector {
				event.Instigators = nil
			}
			if event.Targets == selector {
				event.Targets = nil
			}
		}
		
		// remove from story
		if let idx = _identifiables.firstIndex(where: {$0.UUID == selector.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Selector (\(selector.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteSelector(story: self, selector: selector)}
	}
	func delete(hub: NVHub) {
		Observers.forEach{$0.nvStoryWillDeleteHub(story: self, hub: hub)}
		
		// TODO: Delete hub from groups and sequences when they delete above.
		
		// remove from all groups
		Groups.forEach { (group) in
			if group.contains(hub: hub) {
				group.remove(hub: hub)
			}
		}
		
		// remove from all sequences
		Sequences.forEach { (sequence) in
			if sequence.contains(hub: hub) {
				sequence.remove(hub: hub)
			}
		}
		
		// remove from model
		if let idx = _identifiables.firstIndex(where: {$0.UUID == hub.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		NVLog.log("Deleted Hub (\(hub.UUID.uuidString)).", level: .info)
		Observers.forEach{$0.nvStoryDidDeleteHub(story: self, hub: hub)}
	}
	func delete(rtrn: NVReturn) {
		Observers.forEach{$0.nvStoryWillDeleteReturn(story: self, rtrn: rtrn)}
		
		// TODO: Delete return from groups and sequences when they delete above.
		
		// remove from all groups
		Groups.forEach { (group) in
			if group.contains(rtrn: rtrn) {
				group.remove(rtrn: rtrn)
			}
		}
		
		// remove from all sequences
		Sequences.forEach { (sequence) in
			if sequence.contains(rtrn: rtrn) {
				sequence.remove(rtrn: rtrn)
			}
		}
		
		// remove from model
		if let idx = _identifiables.firstIndex(where: {$0.UUID == rtrn.UUID}) {
			_identifiables.remove(at: idx)
		}
		
		Observers.forEach{$0.nvStoryDidDeleteReturn(story: self, rtrn: rtrn)}
	}
	
	func debugPrint() {
		print("--- BEGIN STORY DEBUG PRINT ---")
		
		print("Groups: \(Groups.count)")
		print("Sequences: \(Sequences.count)")
		print("Discoverables: \(Discoverables.count)")
		print("Events: \(Events.count)")
		print("Entities: \(Entities.count)")
		print("Links: \(Links.count)")
		print("Variables: \(Variables.count)")
		print("Functions: \(Functions.count)")
		print("Conditions: \(Conditions.count)")
		print("Selectors: \(Selectors.count)")
		print("Hubs: \(Hubs.count)")
		print("Returns: \(Returns.count)")
		print()
		
		MainGroup.debugPrint(indent: 0)
		
		print()
		print("--- END STORY DEBUG PRINT ---")
	}
}

private extension NVStory {
	struct Observation {
		weak var observer: NVStoryObserver?
	}
}
