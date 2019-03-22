//
//  NVStoryJSON.swift
//  novella
//
//  Created by Daniel Green on 22/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

typealias JSONDict = [String:Any]

extension NVStory {
	func toJSON() -> String {
		
		var root: JSONDict = [:]
		
		// variables
		var variables: [JSONDict] = []
		self.Variables.forEach{ (variable) in
			var entry: JSONDict = [:]
			entry["id"] = variable.UUID.uuidString
			entry["label"] = variable.Name
			entry["constant"] = variable.Constant
			switch variable.InitialValue.Raw.type {
			case .boolean:
				entry["value"] = variable.InitialValue.Raw.asBool
			case .integer:
				entry["value"] = variable.InitialValue.Raw.asInt
			case .double:
				entry["value"] = variable.InitialValue.Raw.asDouble
			}
			variables.append(entry)
		}
		root["variables"] = variables
		
		// functions
		var functions: [JSONDict] = []
		self.Functions.forEach{ (function) in
			var entry: JSONDict = [:]
			entry["id"] = function.UUID.uuidString
			entry["code"] = function.Code
			functions.append(entry)
		}
		root["functions"] = functions
		
		// conditions
		var conditions: [JSONDict] = []
		self.Conditions.forEach{ (condition) in
			var entry: JSONDict = [:]
			entry["id"] = condition.UUID.uuidString
			entry["code"] = condition.Code
			conditions.append(entry)
		}
		root["conditions"] = conditions
		
		// selectors
		var selectors: [JSONDict] = []
		self.Selectors.forEach{ (selector) in
			var entry: JSONDict = [:]
			entry["id"] = selector.UUID.uuidString
			entry["code"] = selector.Code
			selectors.append(entry)
		}
		root["selectors"] = selectors
		
		// entities (and tags)
		var entities: [JSONDict] = []
		self.Entities.forEach{ (entity) in
			var entry: JSONDict = [:]
			entry["id"] = entity.UUID.uuidString
			entry["label"] = entity.Label
			entry["desc"] = entity.Description
			entry["tags"] = entity.Tags
			entities.append(entry)
		}
		root["entities"] = entities
		
		// links
		var links: [JSONDict] = []
		self.EventLinks.forEach{ (eventLink) in
			var entry: JSONDict = [:]
			entry["id"] = eventLink.UUID.uuidString
			entry["origin"] = eventLink.Origin.UUID.uuidString
			entry["dest"] = eventLink.Destination?.UUID.uuidString ?? ""
			entry["function"] = eventLink.Function?.UUID.uuidString ?? ""
			entry["condition"] = eventLink.Condition?.UUID.uuidString ?? ""
			links.append(entry)
		}
		self.SequenceLinks.forEach{ (seqLink) in
			var entry: JSONDict = [:]
			entry["id"] = seqLink.UUID.uuidString
			entry["origin"] = seqLink.Origin.UUID.uuidString
			entry["dest"] = seqLink.Destination?.UUID.uuidString ?? ""
			entry["function"] = seqLink.Function?.UUID.uuidString ?? ""
			entry["condition"] = seqLink.Condition?.UUID.uuidString ?? ""
			links.append(entry)
		}
		root["links"] = links
		
		// groups
		var groups: [JSONDict] = []
		self.Groups.forEach{ (group) in
			groups.append(groupToJSON(group: group))
		}
		root["groups"] = groups
		
		// sequences
		var sequences: [JSONDict] = []
		self.Sequences.forEach{ (sequence) in
			sequences.append(sequenceToJSON(sequence: sequence))
		}
		root["sequences"] = sequences
		
		// discoverable (as a derivative of sequence)
		var discoverables: [JSONDict] = []
		self.Discoverables.forEach{ (discoverable) in
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
		self.Events.forEach{ (event) in
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
			print("TODO: Export attributes for Events.")
			events.append(entry)
		}
		root["events"] = events
		
		// main group
		root["maingroup"] = groupToJSON(group: self.MainGroup)
		
		// valid JSON object check
		if !JSONSerialization.isValidJSONObject(root) {
			print("JSON object is invalid.")
			return ""
		}
		
		// get data
		guard let jsonData = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted]) else {
			print("Failed to get JSON Data.")
			return ""
		}
		
		guard let jsonString = String(data: jsonData, encoding: .utf8) else {
			print("Failed to get JSON String from Data.")
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
		entry["exitFunction"] = group.ExitFunction?.UUID.uuidString ?? ""
		entry["entry"] = group.Entry?.UUID.uuidString ?? ""
		entry["sequences"] = group.Sequences.map{$0.UUID.uuidString}
		entry["links"] = group.SequenceLinks.map{$0.UUID.uuidString}
		entry["groups"] = group.Groups.map{$0.UUID.uuidString}
		print("TODO: Export attributes for Groups.")
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
		print("TODO: Export attributes for Sequences.")
		return entry
	}
}
