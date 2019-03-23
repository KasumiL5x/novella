//
//  Document+fromJSON.swift
//  novella
//
//  Created by Daniel Green on 23/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa
import SwiftyJSON

extension Document {
	// note: due to how Swift's templates work, this function MUST be called like so (or similar):
	//       let _: T = findbyIDFromJSON(...)    # in this case, T should be replaced by the actual type.
	//         INSTEAD OF: findbyIDFromJSON<T>(...) as the compiler doesn't have enough information from this.
	@discardableResult
	private func findbyIDFromJSON<T>(json: JSON, name: String, checkEmpty: Bool, onSuccess: (T) -> Void, onFail: (String) -> Void) -> T? {
		let id = json[name].stringValue
		if !checkEmpty || (checkEmpty && !id.isEmpty) {
			if let found = Story.find(uuid: id) as? T {
				onSuccess(found)
				return found
			} else {
				onFail(id)
			}
		}
		return nil
	}
	
	fileprivate func parseVariable(variable: JSON, id: NSUUID) {
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
	
	fileprivate func parseFunction(function: JSON, id: NSUUID) {
		let entry = Story.makeFunction(uuid: id)
		entry.Code = function["code"].stringValue
	}
	
	fileprivate func parseCondition(condition: JSON, id: NSUUID) {
		let entry = Story.makeCondition(uuid: id)
		entry.Code = condition["code"].stringValue
	}
	
	fileprivate func parseSelector(selector: JSON, id: NSUUID) {
		let entry = Story.makeSelector(uuid: id)
		entry.Code = selector["code"].stringValue
	}
	
	fileprivate func parseEntity(entity: JSON, id: NSUUID) {
		let entry = Story.makeEntity(uuid: id)
		entry.Label = entity["label"].stringValue
		entry.Description = entity["desc"].stringValue
		entry.Tags = entity["tags"].arrayValue.map{$0.stringValue}
	}
	
	fileprivate func parseEvent(event: JSON, id: NSUUID) {
		let entry = Story.makeEvent(uuid: id)
		entry.Label = event["label"].stringValue
		entry.Parallel = event["parallel"].boolValue
		entry.Topmost = event["topmost"].boolValue
		entry.MaxActivations = event["maxactivations"].intValue
		entry.KeepAlive = event["keepalive"].boolValue
		
		//position (x/y)
		Positions[id] = NSMakePoint(CGFloat(event["position"]["x"].floatValue), CGFloat(event["position"]["y"].floatValue))
		
		// condition
		let _: NVCondition? = findbyIDFromJSON(json: event, name: "condition", checkEmpty: true, onSuccess: { (found) in
			entry.PreCondition = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Condition by ID (\(searchedID)) when setting Event's Condition (\(id.uuidString)).")
		})
		
		// entryfunction
		let _: NVFunction? = findbyIDFromJSON(json: event, name: "entryfunction", checkEmpty: true, onSuccess: { (found) in
			entry.EntryFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Event's EntryFunction (\(id.uuidString)).")
		})
		
		// dofunction
		let _: NVFunction? = findbyIDFromJSON(json: event, name: "dofunction", checkEmpty: true, onSuccess: {(found) in
			entry.DoFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Event's DoFunction (\(id.uuidString)).")
		})
		
		// exitfunction
		let _: NVFunction? = findbyIDFromJSON(json: event, name: "exitfunction", checkEmpty: true, onSuccess: {(found) in
			entry.ExitFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Event's ExitFunction (\(id.uuidString)).")
		})
		
		// instigators
		let _: NVSelector? = findbyIDFromJSON(json: event, name: "instigators", checkEmpty: true, onSuccess: {(found) in
			entry.Instigators = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Selector by ID (\(searchedID)) when setting Event's Instigators (\(id.uuidString)).")
		})
		
		// targets
		let _: NVSelector? = findbyIDFromJSON(json: event, name: "targets", checkEmpty: true, onSuccess: {(found) in
			entry.Targets = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Selector by ID (\(searchedID)) when setting Event's Targets (\(id.uuidString)).")
		})
		
		Swift.print("TODO: Event's attributes")
	}
	
	fileprivate func parseSequence(sequence: JSON, id: NSUUID) {
		let entry = Story.makeSequence(uuid: id)
		entry.Label = sequence["label"].stringValue
		entry.Parallel = sequence["parallel"].boolValue
		entry.Topmost = sequence["topmost"].boolValue
		entry.MaxActivations = sequence["maxactivations"].intValue
		entry.KeepAlive = sequence["keepalive"].boolValue
		
		//position (x/y)
		Positions[id] = NSMakePoint(CGFloat(sequence["position"]["x"].floatValue), CGFloat(sequence["position"]["y"].floatValue))
		
		// condition
		let _: NVCondition? = findbyIDFromJSON(json: sequence, name: "condition", checkEmpty: true, onSuccess: {(found) in
			entry.PreCondition = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Condition by ID (\(searchedID)) when setting Sequence's Condition (\(id.uuidString)).")
		})
		
		// entryfunction
		let _: NVFunction? = findbyIDFromJSON(json: sequence, name: "entryfunction", checkEmpty: true, onSuccess: {(found) in
			entry.EntryFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Sequence's EntryFunction (\(id.uuidString)).")
		})
		
		// exitfunction
		let _: NVFunction? = findbyIDFromJSON(json: sequence, name: "exitfunction", checkEmpty: true, onSuccess: {(found) in
			entry.ExitFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Sequence's ExitFunction (\(id.uuidString)).")
		})
		
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
		let _: NVEvent? = findbyIDFromJSON(json: sequence, name: "entry", checkEmpty: true, onSuccess: {(found) in
			entry.Entry = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Event by ID (\(searchedID)) when setting Sequence's Entry (\(id.uuidString)).")
		})
		
		Swift.print("TODO: Sequence's attributes")
	}
	
	fileprivate func parseDiscoverable(discoverable: JSON, id: NSUUID) {
		let entry = Story.makeDNSequence(uuid: id)
		entry.Label = discoverable["label"].stringValue
		entry.Parallel = discoverable["parallel"].boolValue
		entry.Topmost = discoverable["topmost"].boolValue
		entry.MaxActivations = discoverable["maxactivations"].intValue
		entry.KeepAlive = discoverable["keepalive"].boolValue
		
		//position (x/y)
		Positions[id] = NSMakePoint(CGFloat(discoverable["position"]["x"].floatValue), CGFloat(discoverable["position"]["y"].floatValue))
		
		// condition
		let _: NVCondition? = findbyIDFromJSON(json: discoverable, name: "condition", checkEmpty: true, onSuccess: {(found) in
			entry.PreCondition = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Condition by ID (\(searchedID)) when setting DiscoverableSequence's Condition (\(id.uuidString)).")
		})
		
		// entryfunction
		let _: NVFunction? = findbyIDFromJSON(json: discoverable, name: "entryfunction", checkEmpty: true, onSuccess: {(found) in
			entry.EntryFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting DiscoverableSequence's EntryFunction (\(id.uuidString)).")
		})
		
		// exitfunction
		let _: NVFunction? = findbyIDFromJSON(json: discoverable, name: "exitfunction", checkEmpty: true, onSuccess: {(found) in
			entry.ExitFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting DiscoverableSequence's ExitFunction (\(id.uuidString)).")
		})
		
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
		let _: NVEvent? = findbyIDFromJSON(json: discoverable, name: "entry", checkEmpty: true, onSuccess: {(found) in
			entry.Entry = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Event by ID (\(searchedID)) when setting Sequence's Entry (\(id.uuidString)).")
		})
		
		// (i should make the enum have a fromString function?)
		//tangibility
		Swift.print("TODO: DiscoverableSequence's tangibility")
		Swift.print("TODO: DiscoverableSequence's functionality")
		Swift.print("TODO: DiscoverableSequence's clarity")
		Swift.print("TODO: DiscoverableSequence's delivery")
		
		Swift.print("TODO: DiscoverableSequence's attributes")
	}
	
	fileprivate func parseGroup(group: JSON, id: NSUUID) {
		let entry = Story.makeGroup(uuid: id)
		entry.Label = group["label"].stringValue
		entry.Topmost = group["topmost"].boolValue
		entry.MaxActivations = group["maxactivations"].intValue
		entry.KeepAlive = group["keepalive"].boolValue
		
		//position (x/y)
		Positions[id] = NSMakePoint(CGFloat(group["position"]["x"].floatValue), CGFloat(group["position"]["y"].floatValue))
		
		// condition
		let _: NVCondition? = findbyIDFromJSON(json: group, name: "condition", checkEmpty: true, onSuccess: {(found) in
			entry.PreCondition = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Condition by ID (\(searchedID)) when setting Group's Condition (\(id.uuidString)).")
		})
		
		// entryfunction
		let _: NVFunction? = findbyIDFromJSON(json: group, name: "entryfunction", checkEmpty: true, onSuccess: {(found) in
			entry.EntryFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Group's EntryFunction (\(id.uuidString)).")
		})
		
		// exitfunction
		let _: NVFunction? = findbyIDFromJSON(json: group, name: "exitfunction", checkEmpty: true, onSuccess: {(found) in
			entry.ExitFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Group's ExitFunction (\(id.uuidString)).")
		})
		
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
		let _: NVSequence? = findbyIDFromJSON(json: group, name: "entry", checkEmpty: true, onSuccess: {(found) in
			entry.Entry = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Sequence by ID (\(searchedID)) when setting Group's Entry (\(id.uuidString)).")
		})
		
		Swift.print("TODO: Group's attributes")
	}
	
	func fromJSON(data: Data) -> Bool {
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
			parseVariable(variable: variable, id: id)
		}
		
		// read functions
		for function in json["functions"].arrayValue {
			guard let id = NSUUID(uuidString: function["id"].stringValue) else {
				Swift.print("Failed to load Function as the ID was invalid (\(function["id"].stringValue)).")
				continue
			}
			parseFunction(function: function, id: id)
		}
		
		// read conditions
		for condition in json["conditions"].arrayValue {
			guard let id = NSUUID(uuidString: condition["id"].stringValue) else {
				Swift.print("Failed to load Condition as the ID was invalid (\(condition["id"].stringValue)).")
				continue
			}
			parseCondition(condition: condition, id: id)
		}
		
		// read selectors
		for selector in json["selectors"].arrayValue {
			guard let id = NSUUID(uuidString: selector["id"].stringValue) else {
				Swift.print("Failed to load Selector as the ID was invalid (\(selector["id"].stringValue)).")
				continue
			}
			parseSelector(selector: selector, id: id)
		}
		
		// read entities (and tags)
		for entity in json["entities"].arrayValue {
			guard let id = NSUUID(uuidString: entity["id"].stringValue) else {
				Swift.print("Failed to load Entity as the ID was invalid (\(entity["id"].stringValue)).")
				continue
			}
			parseEntity(entity: entity, id: id)
		}
		
		// read events
		for event in json["events"].arrayValue {
			guard let id = NSUUID(uuidString: event["id"].stringValue) else {
				Swift.print("Failed to load Event as the ID was invalid (\(event["id"].stringValue)).")
				continue
			}
			parseEvent(event: event, id: id)
		}
		
		// read sequences
		for sequence in json["sequences"].arrayValue {
			guard let id = NSUUID(uuidString: sequence["id"].stringValue) else {
				Swift.print("Failed to load Sequence as the ID was invalid (\(sequence["id"].stringValue)).")
				continue
			}
			parseSequence(sequence: sequence, id: id)
		}
		
		// read discoverable sequences
		for discoverable in json["discoverables"].arrayValue {
			guard let id = NSUUID(uuidString: discoverable["id"].stringValue) else {
				Swift.print("Failed to load DiscoverableSequence as the ID was invalid (\(discoverable["id"].stringValue)).")
				continue
			}
			parseDiscoverable(discoverable: discoverable, id: id)
		}
		
		// read groups
		for group in json["groups"].arrayValue {
			guard let id = NSUUID(uuidString: group["id"].stringValue) else {
				Swift.print("Failed to load Group as the ID was invalid (\(group["id"].stringValue)).")
				continue
			}
			parseGroup(group: group, id: id)
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
			let _: NVCondition? = findbyIDFromJSON(json: link, name: "condition", checkEmpty: true, onSuccess: {(found) in
				entry.Condition = found
			}, onFail: {(searchedID) in
				Swift.print("Unable to find Condition by ID (\(searchedID)) when setting EventLink's Condition (\(id.uuidString)).")
			})
			
			// function
			let _: NVFunction? = findbyIDFromJSON(json: link, name: "condition", checkEmpty: true, onSuccess: {(found) in
				entry.Function = found
			}, onFail: {(searchedID) in
				Swift.print("Unable to find Function by ID (\(searchedID)) when setting EventLink's Function (\(id.uuidString)).")
			})
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
			let _: NVCondition? = findbyIDFromJSON(json: link, name: "condition", checkEmpty: true, onSuccess: {(found) in
				entry.Condition = found
			}, onFail: {(searchedID) in
				Swift.print("Unable to find Condition by ID (\(searchedID)) when setting EventLink's Condition (\(id.uuidString)).")
			})
			
			// function
			let _: NVFunction? = findbyIDFromJSON(json: link, name: "condition", checkEmpty: true, onSuccess: {(found) in
				entry.Function = found
			}, onFail: {(searchedID) in
				Swift.print("Unable to find Function by ID (\(searchedID)) when setting EventLink's Function (\(id.uuidString)).")
			})
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
		let _: NVFunction? = findbyIDFromJSON(json: mainGroup, name: "entryfunction", checkEmpty: true, onSuccess: {(found) in
			Story.MainGroup.EntryFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Main Group's EntryFunction.")
		})
		// exitFunction
		let _: NVFunction? = findbyIDFromJSON(json: mainGroup, name: "exitfunction", checkEmpty: true, onSuccess: {(found) in
			Story.MainGroup.ExitFunction = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Function by ID (\(searchedID)) when setting Main Group's ExitFunction.")
		})
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
		let _: NVSequence? = findbyIDFromJSON(json: mainGroup, name: "entry", checkEmpty: true, onSuccess: {(found) in
			Story.MainGroup.Entry = found
		}, onFail: {(searchedID) in
			Swift.print("Unable to find Sequence by ID (\(searchedID)) when setting Main Group's Entry.")
		})
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
