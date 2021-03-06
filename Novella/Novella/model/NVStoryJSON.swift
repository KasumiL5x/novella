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
		var eventLinks: [JSONDict] = []
		self.Links.forEach{ (eventLink) in
			var entry: JSONDict = [:]
			entry["id"] = eventLink.UUID.uuidString
			entry["origin"] = eventLink.Origin.UUID.uuidString
			entry["dest"] = eventLink.Destination?.UUID.uuidString ?? ""
			entry["function"] = eventLink.Function?.UUID.uuidString ?? ""
			entry["condition"] = eventLink.Condition?.UUID.uuidString ?? ""
			eventLinks.append(entry)
		}
		root["links"] = eventLinks
		
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
			
			var attribs: JSONDict = [:]
			for (attrKey, attrValue) in event.Attributes {
				attribs[attrKey as! String] = (attrValue as! String)
			}
			entry["attributes"] = attribs
			
			events.append(entry)
		}
		root["events"] = events
		
		// hubs
		var hubs: [JSONDict] = []
		self.Hubs.forEach { (hub) in
			var entry: JSONDict = [:]
			entry["id"] = hub.UUID.uuidString
			entry["label"] = hub.Label
			entry["condition"] = hub.Condition?.UUID.uuidString ?? ""
			entry["entryfunction"] = hub.EntryFunction?.UUID.uuidString ?? ""
			entry["returnfunction"] = hub.ReturnFunction?.UUID.uuidString ?? ""
			entry["exitfunction"] = hub.ExitFunction?.UUID.uuidString ?? ""
			hubs.append(entry)
		}
		root["hubs"] = hubs
		
		// returns
		var rtrns: [JSONDict] = []
		self.Returns.forEach { (rtrn) in
			var entry: JSONDict = [:]
			entry["id"] = rtrn.UUID.uuidString
			entry["label"] = rtrn.Label
			entry["exitfunction"] = rtrn.ExitFunction?.UUID.uuidString ?? ""
			rtrns.append(entry)
		}
		root["returns"] = rtrns
		
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
		entry["exitfunction"] = group.ExitFunction?.UUID.uuidString ?? ""
		entry["entry"] = group.Entry?.UUID.uuidString ?? ""
		entry["sequences"] = group.Sequences.map{$0.UUID.uuidString}
		entry["links"] = group.Links.map{$0.UUID.uuidString}
		entry["groups"] = group.Groups.map{$0.UUID.uuidString}
		entry["hubs"] = group.Hubs.map{$0.UUID.uuidString}
		entry["returns"] = group.Returns.map{$0.UUID.uuidString}
		
		var attribs: JSONDict = [:]
		for (attrKey, attrValue) in group.Attributes {
			attribs[attrKey as! String] = (attrValue as! String)
		}
		entry["attributes"] = attribs
		
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
		entry["links"] = sequence.Links.map{$0.UUID.uuidString}
		entry["hubs"] = sequence.Hubs.map{$0.UUID.uuidString}
		entry["returns"] = sequence.Returns.map{$0.UUID.uuidString}
		
		var attribs: JSONDict = [:]
		for (attrKey, attrValue) in sequence.Attributes {
			attribs[attrKey as! String] = (attrValue as! String)
		}
		entry["attributes"] = attribs
		
		return entry
	}
}
