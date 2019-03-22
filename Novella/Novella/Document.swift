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
		guard fromJSON(data: data) else {
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
		Story.Functions.forEach{ (function) in
			var entry: JSONDict = [:]
			entry["id"] = function.UUID.uuidString
			entry["code"] = function.Code
			functions.append(entry)
		}
		root["functions"] = functions
		
		// conditions
		var conditions: [JSONDict] = []
		Story.Conditions.forEach{ (condition) in
			var entry: JSONDict = [:]
			entry["id"] = condition.UUID.uuidString
			entry["code"] = condition.Code
			conditions.append(entry)
		}
		root["conditions"] = conditions
		
		// selectors
		var selectors: [JSONDict] = []
		Story.Selectors.forEach{ (selector) in
			var entry: JSONDict = [:]
			entry["id"] = selector.UUID.uuidString
			entry["code"] = selector.Code
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
	
	private func fromJSON(data: Data) -> Bool {
		guard let json = try? JSON(data: data, options: []) else {
			Swift.print("Failed to create JSON object from Data.")
			return false
		}
		
		Swift.print(json)
		
		// read variables
		for variable in json["variables"].arrayValue {
			guard let id = NSUUID(uuidString: variable["id"].stringValue) else {
				Swift.print("Failed to load Variable as the ID was invalid (\(variable["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeVariable(uuid: id)
			entry.Name = variable["label"].stringValue
			entry.Constant = variable["constant"].boolValue
			if let asBool = variable["value"].bool {
				entry.set(initialValue: NVValue(.boolean(asBool)))
			} else if let asInt = variable["value"].int32 {
				entry.set(initialValue: NVValue(.integer(asInt)))
			} else if let asDouble = variable["value"].double {
				entry.set(initialValue: NVValue(.double(asDouble)))
			}
		}
		
		// read functions
		for function in json["functions"].arrayValue {
			guard let id = NSUUID(uuidString: function["id"].stringValue) else {
				Swift.print("Failed to load Function as the ID was invalid (\(function["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeFunction(uuid: id)
			entry.Code = function["code"].stringValue
		}
		
		// read conditions
		for condition in json["conditions"].arrayValue {
			guard let id = NSUUID(uuidString: condition["id"].stringValue) else {
				Swift.print("Failed to load Condition as the ID was invalid (\(condition["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeCondition(uuid: id)
			entry.Code = condition["code"].stringValue
		}
		
		// read selectors
		for selector in json["selectors"].arrayValue {
			guard let id = NSUUID(uuidString: selector["id"].stringValue) else {
				Swift.print("Failed to load Selector as the ID was invalid (\(selector["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeSelector(uuid: id)
			entry.Code = selector["code"].stringValue
		}
		
		// read entities (and tags)
		for entity in json["entities"].arrayValue {
			guard let id = NSUUID(uuidString: entity["id"].stringValue) else {
				Swift.print("Failed to load Entity as the ID was invalid (\(entity["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeEntity(uuid: id)
			entry.Label = entity["label"].stringValue
			entry.Description = entity["desc"].stringValue
			entry.Tags = entity["tags"].arrayValue.map{$0.stringValue}
		}
		
		// read events
		for event in json["events"].arrayValue {
			guard let id = NSUUID(uuidString: event["id"].stringValue) else {
				Swift.print("Failed to load Event as the ID was invalid (\(event["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeEvent(uuid: id)
			entry.Label = event["label"].stringValue
			entry.Parallel = event["parallel"].boolValue
			entry.Topmost = event["topmost"].boolValue
			entry.MaxActivations = event["maxactivations"].intValue
			entry.KeepAlive = event["keepalive"].boolValue
			
			//position (x/y)
			Positions[id] = NSMakePoint(CGFloat(event["position"]["x"].floatValue), CGFloat(event["position"]["y"].floatValue))
			
			// condition
			let conditionID = event["condition"].stringValue
			if !conditionID.isEmpty, let found = Story.find(uuid: conditionID) as? NVCondition {
				entry.PreCondition = found
			} else {
				Swift.print("Unable to find Condition by ID (\(conditionID)) when setting Event's Condition (\(id.uuidString)).")
			}
			
			// entryfunction
			let entryfunctionID = event["entryfunction"].stringValue
			if !entryfunctionID.isEmpty, let found = Story.find(uuid: entryfunctionID) as? NVFunction {
				entry.EntryFunction = found
			} else {
				Swift.print("Unable to find Function by ID (\(entryfunctionID)) when setting Event's EntryFunction (\(id.uuidString)).")
			}
			
			// dofunction
			let dofunctionID = event["dofunction"].stringValue
			if !dofunctionID.isEmpty, let found = Story.find(uuid: dofunctionID) as? NVFunction {
				entry.DoFunction = found
			} else {
				Swift.print("Unable to find Function by ID (\(dofunctionID)) when setting Event's DoFunction (\(id.uuidString)).")
			}
			
			// exitfunction
			let exitFunctionID = event["exitfunction"].stringValue
			if !exitFunctionID.isEmpty, let found = Story.find(uuid: exitFunctionID) as? NVFunction {
				entry.ExitFunction = found
			} else {
				Swift.print("Unable to find Function by ID (\(exitFunctionID)) when setting Event's ExitFunction (\(id.uuidString)).")
			}
			
			// instigators
			let instigatorsID = event["instigators"].stringValue
			if !instigatorsID.isEmpty, let found = Story.find(uuid: instigatorsID) as? NVSelector {
				entry.Instigators = found
			} else {
				Swift.print("Unable to find Selector by ID (\(instigatorsID)) when setting Event's Instigators (\(id.uuidString)).")
			}
			
			// targets
			let targetsID = event["targets"].stringValue
			if !targetsID.isEmpty, let found = Story.find(uuid: targetsID) as? NVSelector {
				entry.Targets = found
			} else {
				Swift.print("Unable to find Selector by ID (\(targetsID)) when setting Event's Targets (\(id.uuidString)).")
			}
			
			Swift.print("TODO: Event's attributes")
		}
		
		// read sequences
		for sequence in json["sequences"].arrayValue {
			guard let id = NSUUID(uuidString: sequence["id"].stringValue) else {
				Swift.print("Failed to load Sequence as the ID was invalid (\(sequence["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeSequence(uuid: id)
			entry.Label = sequence["label"].stringValue
			entry.Parallel = sequence["parallel"].boolValue
			entry.Topmost = sequence["topmost"].boolValue
			entry.MaxActivations = sequence["maxactivations"].intValue
			entry.KeepAlive = sequence["keepalive"].boolValue
			
			//position (x/y)
			Positions[id] = NSMakePoint(CGFloat(sequence["position"]["x"].floatValue), CGFloat(sequence["position"]["y"].floatValue))
			
			// condition
			let conditionID = sequence["condition"].stringValue
			if !conditionID.isEmpty {
				if let found = Story.find(uuid: conditionID) as? NVCondition {
					entry.PreCondition = found
				} else {
					Swift.print("Unable to find Condition by ID (\(conditionID)) when setting Sequence's Condition (\(id.uuidString)).")
				}
			}
			
			// entryfunction
			let entryfunctionID = sequence["entryfunction"].stringValue
			if !entryfunctionID.isEmpty {
				if let found = Story.find(uuid: entryfunctionID) as? NVFunction {
					entry.EntryFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(entryfunctionID)) when setting Sequence's EntryFunction (\(id.uuidString)).")
				}
			}
			
			// exitfunction
			let exitFunctionID = sequence["exitfunction"].stringValue
			if !exitFunctionID.isEmpty {
				if let found = Story.find(uuid: exitFunctionID) as? NVFunction {
					entry.ExitFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(exitFunctionID)) when setting Sequence's ExitFunction (\(id.uuidString)).")
				}
			}
			
			// events
			sequence["events"].arrayValue.forEach { (child) in
				let childID = child.stringValue
				if let found = Story.find(uuid: childID) as? NVEvent {
					entry.add(event: found)
				} else {
					Swift.print("Unable to find Event by ID (\(childID)) when adding an Entry to Sequence (\(id.uuidString)).")
				}
			}
			
			// entry
			let entryID = sequence["entry"].stringValue
			if !entryID.isEmpty {
				if let found = Story.find(uuid: entryID) as? NVEvent {
					entry.Entry = found
				} else {
					Swift.print("Unable to find Event by ID (\(entryID)) when setting Sequence's Entry (\(id.uuidString)).")
				}
			}
			
			Swift.print("TODO: Sequence's attributes")
		}
		
		// read discoverable sequences
		for discoverable in json["discoverables"].arrayValue {
			guard let id = NSUUID(uuidString: discoverable["id"].stringValue) else {
				Swift.print("Failed to load DiscoverableSequence as the ID was invalid (\(discoverable["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeDNSequence(uuid: id)
			entry.Label = discoverable["label"].stringValue
			entry.Parallel = discoverable["parallel"].boolValue
			entry.Topmost = discoverable["topmost"].boolValue
			entry.MaxActivations = discoverable["maxactivations"].intValue
			entry.KeepAlive = discoverable["keepalive"].boolValue
			
			//position (x/y)
			Positions[id] = NSMakePoint(CGFloat(discoverable["position"]["x"].floatValue), CGFloat(discoverable["position"]["y"].floatValue))
			
			// condition
			let conditionID = discoverable["condition"].stringValue
			if !conditionID.isEmpty {
				if let found = Story.find(uuid: conditionID) as? NVCondition {
					entry.PreCondition = found
				} else {
					Swift.print("Unable to find Condition by ID (\(conditionID)) when setting DiscoverableSequence's Condition (\(id.uuidString)).")
				}
			}
			
			// entryfunction
			let entryfunctionID = discoverable["entryfunction"].stringValue
			if !entryfunctionID.isEmpty {
				if let found = Story.find(uuid: entryfunctionID) as? NVFunction {
					entry.EntryFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(entryfunctionID)) when setting DiscoverableSequence's EntryFunction (\(id.uuidString)).")
				}
			}
			
			// exitfunction
			let exitFunctionID = discoverable["exitfunction"].stringValue
			if !exitFunctionID.isEmpty {
				if let found = Story.find(uuid: exitFunctionID) as? NVFunction {
					entry.ExitFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(exitFunctionID)) when setting DiscoverableSequence's ExitFunction (\(id.uuidString)).")
				}
			}
			
			// events
			discoverable["events"].arrayValue.forEach { (child) in
				let childID = child.stringValue
				if let found = Story.find(uuid: childID) as? NVEvent {
					entry.add(event: found)
				} else {
					Swift.print("Unable to find Event by ID (\(childID)) when adding an Entry to Sequence (\(id.uuidString)).")
				}
			}
			
			// entry
			let entryID = discoverable["entry"].stringValue
			if !entryID.isEmpty {
				if let found = Story.find(uuid: entryID) as? NVEvent {
					entry.Entry = found
				} else {
					Swift.print("Unable to find Event by ID (\(entryID)) when setting Sequence's Entry (\(id.uuidString)).")
				}
			}
			
			// (i should make the enum have a fromString function?)
			//tangibility
			Swift.print("TODO: DiscoverableSequence's tangibility")
			Swift.print("TODO: DiscoverableSequence's functionality")
			Swift.print("TODO: DiscoverableSequence's clarity")
			Swift.print("TODO: DiscoverableSequence's delivery")
			
			Swift.print("TODO: DiscoverableSequence's attributes")
		}
		
		// read groups
		for group in json["groups"].arrayValue {
			guard let id = NSUUID(uuidString: group["id"].stringValue) else {
				Swift.print("Failed to load Group as the ID was invalid (\(group["id"].stringValue)).")
				continue
			}
			
			let entry = Story.makeGroup(uuid: id)
			entry.Label = group["label"].stringValue
			entry.Topmost = group["topmost"].boolValue
			entry.MaxActivations = group["maxactivations"].intValue
			entry.KeepAlive = group["keepalive"].boolValue
			
			//position (x/y)
			Positions[id] = NSMakePoint(CGFloat(group["position"]["x"].floatValue), CGFloat(group["position"]["y"].floatValue))
			
			// condition
			let conditionID = group["condition"].stringValue
			if !conditionID.isEmpty {
				if let found = Story.find(uuid: conditionID) as? NVCondition {
					entry.PreCondition = found
				} else {
					Swift.print("Unable to find Condition by ID (\(conditionID)) when setting Group's Condition (\(id.uuidString)).")
				}
			}
			
			// entryfunction
			let entryfunctionID = group["entryfunction"].stringValue
			if !entryfunctionID.isEmpty {
				if let found = Story.find(uuid: entryfunctionID) as? NVFunction {
					entry.EntryFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(entryfunctionID)) when setting Group's EntryFunction (\(id.uuidString)).")
				}
			}
			
			// exitfunction
			let exitFunctionID = group["exitfunction"].stringValue
			if !exitFunctionID.isEmpty {
				if let found = Story.find(uuid: exitFunctionID) as? NVFunction {
					entry.ExitFunction = found
				} else {
					Swift.print("Unable to find Function by ID (\(exitFunctionID)) when setting Group's ExitFunction (\(id.uuidString)).")
				}
			}
			
			// sequences
			group["sequences"].arrayValue.forEach { (child) in
				let childID = child.stringValue
				if let found = Story.find(uuid: childID) as? NVSequence {
					entry.add(sequence: found)
				} else {
					Swift.print("Unable to find Sequence by ID (\(childID)) when adding an Entry to Group (\(id.uuidString)).")
				}
			}
			
			// entry
			let entryID = group["entry"].stringValue
			if !entryID.isEmpty {
				if let found = Story.find(uuid: entryID) as? NVSequence {
					entry.Entry = found
				} else {
					Swift.print("Unable to find Sequence by ID (\(entryID)) when setting Group's Entry (\(id.uuidString)).")
				}
			}
			
			Swift.print("TODO: Group's attributes")
		}
		
		// read event links
		for link in json["eventlinks"].arrayValue {
			guard let id = NSUUID(uuidString: link["id"].stringValue) else {
				Swift.print("Failed to load Event Link as the ID was invalid (\(link["id"].stringValue)).")
				continue
			}
			
			guard let origin = Story.find(uuid: link["origin"].stringValue) as? NVEvent else {
				Swift.print("Failed to find origin Event (\(link["origin"].stringValue)) when setting up an EventLink (\(id.uuidString)).")
				continue
			}
			let dest = Story.find(uuid: link["dest"].stringValue) as? NVEvent // returns nil if it fails to find, so no check required
			
			let entry = Story.makeEventLink(uuid: id, origin: origin, dest: dest)
			
			// condition
			let conditionID = link["condition"].stringValue
			if !conditionID.isEmpty {
				if let found = Story.find(uuid: conditionID) as? NVCondition {
					entry.Condition = found
				} else {
					Swift.print("Unable to find Condition by ID (\(conditionID)) when setting EventLink's Condition (\(id.uuidString)).")
				}
			}
			
			// function
			let functionID = link["condition"].stringValue
			if !functionID.isEmpty {
				if let found = Story.find(uuid: functionID) as? NVFunction {
					entry.Function = found
				} else {
					Swift.print("Unable to find Function by ID (\(functionID)) when setting EventLink's Function (\(id.uuidString)).")
				}
			}
		}
		
		// read sequence links
		for link in json["sequencelinks"].arrayValue {
			guard let id = NSUUID(uuidString: link["id"].stringValue) else {
				Swift.print("Failed to load SequenceLink as the ID was invalid (\(link["id"].stringValue)).")
				continue
			}
			
			guard let origin = Story.find(uuid: link["origin"].stringValue) as? NVSequence else {
				Swift.print("Failed to find origin Sequence (\(link["origin"].stringValue)) when setting up an SequenceLink (\(id.uuidString)).")
				continue
			}
			let dest = Story.find(uuid: link["dest"].stringValue) as? NVSequence // returns nil if it fails to find, so no check required
			
			let entry = Story.makeSequenceLink(uuid: id, origin: origin, dest: dest)
			
			// condition
			let conditionID = link["condition"].stringValue
			if !conditionID.isEmpty {
				if let found = Story.find(uuid: conditionID) as? NVCondition {
					entry.Condition = found
				} else {
					Swift.print("Unable to find Condition by ID (\(conditionID)) when setting EventLink's Condition (\(id.uuidString)).")
				}
			}
			
			// function
			let functionID = link["condition"].stringValue
			if !functionID.isEmpty {
				if let found = Story.find(uuid: functionID) as? NVFunction {
					entry.Function = found
				} else {
					Swift.print("Unable to find Function by ID (\(functionID)) when setting EventLink's Function (\(id.uuidString)).")
				}
			}
		}
		
		// add sequence links
		for sequence in json["sequences"].arrayValue {
			guard let entry = Story.find(uuid: sequence["id"].stringValue) as? NVSequence else {
				Swift.print("Failed to find Sequence by ID (\(sequence["id"].stringValue)) when adding its links.")
				continue
			}
			
			sequence["links"].arrayValue.forEach{ (link) in
				let childID = link.stringValue
				if let found = Story.find(uuid: childID) as? NVEventLink {
					entry.add(eventLink: found)
				} else {
					Swift.print("Unable to find EventLink by ID (\(childID)) when adding to Sequence (\(sequence["id"].stringValue)).")
				}
			}
		}
		
		// add discoverable sequence links
		for discoverable in json["discoverables"].arrayValue {
			guard let entry = Story.find(uuid: discoverable["id"].stringValue) as? NVDiscoverableSequence else {
				Swift.print("Failed to find DiscoverableSequence by ID (\(discoverable["id"].stringValue)) when adding its links.")
				continue
			}
			
			discoverable["links"].arrayValue.forEach{ (link) in
				let childID = link.stringValue
				if let found = Story.find(uuid: childID) as? NVEventLink {
					entry.add(eventLink: found)
				} else {
					Swift.print("Unable to find EventLink by ID (\(childID)) when adding to DiscoverableSequence (\(discoverable["id"].stringValue)).")
				}
			}
		}
		
		// add groups to groups and links to groups
		for group in json["groups"].arrayValue {
			guard let entry = Story.find(uuid: group["id"].stringValue) as? NVGroup else {
				Swift.print("Failed to find Group by ID (\(group["id"].stringValue)) when adding its groups and links.")
				continue
			}
			
			// links
			group["links"].arrayValue.forEach{ (link) in
				let childID = link.stringValue
				if let found = Story.find(uuid: childID) as? NVSequenceLink {
					entry.add(sequenceLink: found)
				} else {
					Swift.print("Unable to find SequenceLink by ID (\(childID)) when adding to Group (\(group["id"].stringValue)).")
				}
			}
			
			// groups
			group["groups"].arrayValue.forEach{ (link) in
				let childID = link.stringValue
				if let found = Story.find(uuid: childID) as? NVGroup {
					entry.add(group: found)
				} else {
					Swift.print("Unable to find Group by ID (\(childID)) when adding to Group (\(group["id"].stringValue)).")
				}
			}
		}
		
		// main group
		let mainGroup = json["maingroup"]
		// entryfunction
		let mainEntryfunctionID = mainGroup["entryfunction"].stringValue
		if !mainEntryfunctionID.isEmpty {
			if let found = Story.find(uuid: mainEntryfunctionID) as? NVFunction {
				Story.MainGroup.EntryFunction = found
			} else {
				Swift.print("Unable to find Function by ID (\(mainEntryfunctionID)) when setting Main Group's EntryFunction.")
			}
		}
		// exitFunction
		let mainExitFunctionID = mainGroup["exitfunction"].stringValue
		if !mainExitFunctionID.isEmpty {
			if let found = Story.find(uuid: mainExitFunctionID) as? NVFunction {
				Story.MainGroup.ExitFunction = found
			} else {
				Swift.print("Unable to find Function by ID (\(mainExitFunctionID)) when setting Main Group's ExitFunction.")
			}
		}
		// sequences
		mainGroup["sequences"].arrayValue.forEach { (child) in
			let childID = child.stringValue
			if let found = Story.find(uuid: childID) as? NVSequence {
				Story.MainGroup.add(sequence: found)
			} else {
				Swift.print("Unable to find Sequence by ID (\(childID)) when adding a Sequence to the Main Group.")
			}
		}
		// entry
		let mainEntryID = mainGroup["entry"].stringValue
		if !mainEntryID.isEmpty {
			if let found = Story.find(uuid: mainEntryID) as? NVSequence {
				Story.MainGroup.Entry = found
			} else {
				Swift.print("Unable to find Sequence by ID (\(mainEntryID)) when setting Main Group's Entry.")
			}
		}
		// groups
		mainGroup["groups"].arrayValue.forEach{ (child) in
			let childID = child.stringValue
			if let found = Story.find(uuid: childID) as? NVGroup {
				Story.MainGroup.add(group: found)
			} else {
				Swift.print("Unable to find Group by ID (\(childID)) when adding a Group to the Main Group.")
			}
		}
		// links
		mainGroup["links"].arrayValue.forEach{ (child) in
			let childID = child.stringValue
			if let found = Story.find(uuid: childID) as? NVSequenceLink {
				Story.MainGroup.add(sequenceLink: found)
			} else {
				Swift.print("Unable to find SequenceLink by ID (\(childID)) when adding a SequeceLink to the Main Group.")
			}
		}
		
		return true
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
	
	func nvVariableInitialValueDidChange(story: NVStory, variable: NVVariable) {
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
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
	
	func nvSelectorCodeDidChange(story: NVStory, selector: NVSelector) {
		updateChangeCount(.changeDone)
	}
}
