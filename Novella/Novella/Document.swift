//
//  Document.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa
import SwiftyJSON

class Document: NSDocument {
	// additional non-model data
	var Positions: [NSUUID:CGPoint] = [:] {
		didSet { updateChangeCount(.changeDone) }
	}
	
	private(set) var Story: NVStory = NVStory()
	
	override init() {
		super.init()
		Story.add(observer: self)
	}

	override class var autosavesInPlace: Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)
	}

	override func data(ofType typeName: String) throws -> Data {
		let jsonString = saveJSON()
		if jsonString.isEmpty {
			Swift.print("Tried to save JSON but the resulting string was empty.")
			throw NSError(domain: NSOSStatusErrorDomain, code: writErr, userInfo: nil)
		}
		
		guard let jsonData = jsonString.data(using: .utf8) else {
			Swift.print("Tried to save JSON but failed to get Data from the JSON string.")
			throw NSError(domain: NSOSStatusErrorDomain, code: writErr, userInfo: nil)
		}
		return jsonData
	}

	override func read(from data: Data, ofType typeName: String) throws {
		guard self.fromJSON(data: data) else {
			Swift.print("Failed to load from JSON.")
			throw NSError(domain: NSOSStatusErrorDomain, code: readErr, userInfo: nil)
		}
	}
}

extension Document {
	private func saveJSON() -> String {
		// Note: This function is almost identical to NVStory::toJSON(), but it includes extra editor-only information.
		//       It was decided to keep them entirely separate as they shouldn't match or rely on each other.
		var root: JSONDict = [:]
		
		// variables
		var variables: [JSONDict] = []
		Story.Variables.forEach{ (variable) in
			var entry: JSONDict = [:]
			entry["id"] = variable.UUID.uuidString
			entry["label"] = variable.Name
			entry["constant"] = variable.Constant
			switch variable.Value.Raw.type {
			case .boolean:
				entry["value"] = variable.Value.Raw.asBool
				entry["type"] = "boolean"
			case .integer:
				entry["value"] = variable.Value.Raw.asInt
				entry["type"] = "integer"
			case .double:
				entry["value"] = String(format: "%.2f", variable.Value.Raw.asDouble)
				entry["type"] = "double"
			}
			variables.append(entry)
		}
		root["variables"] = variables
		
		// functions
		var functions: [JSONDict] = []
		Story.Functions.forEach{ (function) in
			var entry: JSONDict = [:]
			entry["id"] = function.UUID.uuidString
			entry["code"] = function.Code
			entry["label"] = function.Label
			functions.append(entry)
		}
		root["functions"] = functions
		
		// conditions
		var conditions: [JSONDict] = []
		Story.Conditions.forEach{ (condition) in
			var entry: JSONDict = [:]
			entry["id"] = condition.UUID.uuidString
			entry["code"] = condition.Code
			entry["label"] = condition.Label
			conditions.append(entry)
		}
		root["conditions"] = conditions
		
		// selectors
		var selectors: [JSONDict] = []
		Story.Selectors.forEach{ (selector) in
			var entry: JSONDict = [:]
			entry["id"] = selector.UUID.uuidString
			entry["code"] = selector.Code
			entry["label"] = selector.Label
			selectors.append(entry)
		}
		root["selectors"] = selectors
		
		// entities (and tags)
		var entities: [JSONDict] = []
		Story.Entities.forEach{ (entity) in
			var entry: JSONDict = [:]
			entry["id"] = entity.UUID.uuidString
			entry["label"] = entity.Label
			entry["desc"] = entity.Description
			entry["tags"] = entity.Tags
			entities.append(entry)
		}
		root["entities"] = entities
		
		// event links
		var eventLinks: [JSONDict] = []
		Story.EventLinks.forEach{ (eventLink) in
			var entry: JSONDict = [:]
			entry["id"] = eventLink.UUID.uuidString
			entry["origin"] = eventLink.Origin.UUID.uuidString
			entry["dest"] = eventLink.Destination?.UUID.uuidString ?? ""
			entry["function"] = eventLink.Function?.UUID.uuidString ?? ""
			entry["condition"] = eventLink.Condition?.UUID.uuidString ?? ""
			eventLinks.append(entry)
		}
		root["eventlinks"] = eventLinks
		
		// sequence links
		var sequenceLinks: [JSONDict] = []
		Story.SequenceLinks.forEach{ (seqLink) in
			var entry: JSONDict = [:]
			entry["id"] = seqLink.UUID.uuidString
			entry["origin"] = seqLink.Origin.UUID.uuidString
			entry["dest"] = seqLink.Destination?.UUID.uuidString ?? ""
			entry["function"] = seqLink.Function?.UUID.uuidString ?? ""
			entry["condition"] = seqLink.Condition?.UUID.uuidString ?? ""
			sequenceLinks.append(entry)
		}
		root["sequencelinks"] = sequenceLinks
		
		// groups
		var groups: [JSONDict] = []
		Story.Groups.forEach{ (group) in
			groups.append(groupToJSON(group: group))
		}
		root["groups"] = groups
		
		// sequences
		var sequences: [JSONDict] = []
		Story.Sequences.forEach{ (sequence) in
			sequences.append(sequenceToJSON(sequence: sequence))
		}
		root["sequences"] = sequences
		
		// discoverable (as a derivative of sequence)
		var discoverables: [JSONDict] = []
		Story.Discoverables.forEach{ (discoverable) in
			var entry = sequenceToJSON(sequence: discoverable)
			entry["tangibility"] = discoverable.Tangibility.toString
			entry["functionality"] = discoverable.Functionality.toString
			entry["clarity"] = discoverable.Clarity.toString
			entry["delivery"] = discoverable.Delivery.toString
			discoverables.append(entry)
		}
		root["discoverables"] = discoverables
		
		// events
		var events: [JSONDict] = []
		Story.Events.forEach{ (event) in
			var entry: JSONDict = [:]
			entry["id"] = event.UUID.uuidString
			entry["label"] = event.Label
			entry["parallel"] = event.Parallel
			entry["topmost"] = event.Topmost
			entry["maxactivations"] = event.MaxActivations
			entry["keepalive"] = event.KeepAlive
			entry["condition"] = event.PreCondition?.UUID.uuidString ?? ""
			entry["entryfunction"] = event.EntryFunction?.UUID.uuidString ?? ""
			entry["dofunction"] = event.DoFunction?.UUID.uuidString ?? ""
			entry["exitfunction"] = event.ExitFunction?.UUID.uuidString ?? ""
			entry["instigators"] = event.Instigators?.UUID.uuidString ?? ""
			entry["targets"] = event.Targets?.UUID.uuidString ?? ""
			
			let pos = Positions[event.UUID] ?? CGPoint.zero
			entry["position"] = [
				"x": pos.x,
				"y": pos.y
			]
			
			Swift.print("TODO: Export attributes for Events.")
			events.append(entry)
		}
		root["events"] = events
		
		// main group
		root["maingroup"] = groupToJSON(group: Story.MainGroup)
		
		// valid JSON object check
		if !JSONSerialization.isValidJSONObject(root) {
			Swift.print("JSON object is invalid.")
			return ""
		}
		
		// get data
		guard let jsonData = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted]) else {
			Swift.print("Failed to get JSON Data.")
			return ""
		}
		
		guard let jsonString = String(data: jsonData, encoding: .utf8) else {
			Swift.print("Failed to get JSON String from Data.")
			return ""
		}
		
		return jsonString
	}
	
	private func groupToJSON(group: NVGroup) -> JSONDict {
		var entry: JSONDict = [:]
		entry["id"] = group.UUID.uuidString
		entry["label"] = group.Label
		entry["topmost"] = group.Topmost
		entry["maxactivations"] = group.MaxActivations
		entry["keepalive"] = group.KeepAlive
		entry["condition"] = group.PreCondition?.UUID.uuidString ?? ""
		entry["entryfunction"] = group.EntryFunction?.UUID.uuidString ?? ""
		entry["exitfunction"] = group.ExitFunction?.UUID.uuidString ?? ""
		entry["entry"] = group.Entry?.UUID.uuidString ?? ""
		entry["sequences"] = group.Sequences.map{$0.UUID.uuidString}
		entry["links"] = group.SequenceLinks.map{$0.UUID.uuidString}
		entry["groups"] = group.Groups.map{$0.UUID.uuidString}
		
		let pos = Positions[group.UUID] ?? CGPoint.zero
		entry["position"] = [
			"x": pos.x,
			"y": pos.y
		]
		
		Swift.print("TODO: Export attributes for Groups.")
		return entry
	}
	
	private func sequenceToJSON(sequence: NVSequence) -> JSONDict {
		var entry: JSONDict = [:]
		entry["id"] = sequence.UUID.uuidString
		entry["label"] = sequence.Label
		entry["parallel"] = sequence.Parallel
		entry["topmost"] = sequence.Topmost
		entry["maxactivations"] = sequence.MaxActivations
		entry["keepalive"] = sequence.KeepAlive
		entry["condition"] = sequence.PreCondition?.UUID.uuidString ?? ""
		entry["entryfunction"] = sequence.EntryFunction?.UUID.uuidString ?? ""
		entry["exitfunction"] = sequence.ExitFunction?.UUID.uuidString ?? ""
		entry["entry"] = sequence.Entry?.UUID.uuidString ?? ""
		entry["events"] = sequence.Events.map{$0.UUID.uuidString}
		entry["links"] = sequence.EventLinks.map{$0.UUID.uuidString}
		
		let pos = Positions[sequence.UUID] ?? CGPoint.zero
		entry["position"] = [
			"x": pos.x,
			"y": pos.y
		]
		
		Swift.print("TODO: Export attributes for Sequences.")
		return entry
	}
}

extension Document: NVStoryObserver {
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
		if Positions[group.UUID] == nil {
			Positions[group.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeSequence(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
		if Positions[sequence.UUID] == nil {
			Positions[sequence.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
		if Positions[event.UUID] == nil {
			Positions[event.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
		if Positions[entity.UUID] == nil {
			Positions[entity.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeSequenceLink(story: NVStory, link: NVSequenceLink) {
		updateChangeCount(.changeDone)
		if Positions[link.UUID] == nil {
			Positions[link.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
		updateChangeCount(.changeDone)
		if Positions[link.UUID] == nil {
			Positions[link.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
		if Positions[variable.UUID] == nil {
			Positions[variable.UUID] = CGPoint.zero
		}
	}
	
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidMakeSelector(story: NVStory, selector: NVSelector) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteSequence(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteSequenceLink(story: NVStory, link: NVSequenceLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteSelector(story: NVStory, selector: NVSelector) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupTopmostDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupMaxActivationsDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupKeepAliveDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupConditionDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupEntryFunctionDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupExitFunctionDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupAttributesDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceParallelDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceEntryDidChange(story: NVStory, sequence: NVSequence, oldEntry: NVEvent?, newEntry: NVEvent?) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceTopmostDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceMaxActivationsDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceKeepAliveDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceConditionDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceEntryFunctionDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceExitFunctionDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceAttributesDidChange(story: NVStory, sequence: NVSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNSequenceTangibilityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNSequenceFunctionalityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNSequenceClarityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNSequenceDeliveryDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventTopmostDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventMaxActivationsDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventKeepAliveDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventConditionDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventEntryFunctionDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventDoFunctionDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventExitFunctionDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventInstigatorsDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventTargetsDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventAttributesDidChange(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
	}
	
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
	}
	
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
	}
	
	func nvSequenceLinkDestinationDidChange(story: NVStory, link: NVSequenceLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvEntityTagsDidChange(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
		updateChangeCount(.changeDone)
	}
	
	func nvFunctionLabelDidChange(story: NVStory, function: NVFunction) {
		updateChangeCount(.changeDone)
	}
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
	
	func nvConditionLabelDidChange(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
	
	func nvSelectorCodeDidChange(story: NVStory, selector: NVSelector) {
		updateChangeCount(.changeDone)
	}
	
	func nvSelectorLabelDidChange(story: NVStory, selector: NVSelector) {
		updateChangeCount(.changeDone)
	}
}
