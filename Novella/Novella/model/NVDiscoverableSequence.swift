//
//  NVDiscoverableSequence.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVDiscoverableSequence: NVSequence {
	enum DNTangibility {
		case Tangible
		case Intangible
		
		var toString: String {
			switch self {
			case .Tangible:
				return "tangible"
			case .Intangible:
				return "intangible"
			}
		}
		
		static func fromString(_ str: String) -> DNTangibility {
			switch str {
			case "tangible":
				return .Tangible
			case "intangible":
				return .Intangible
			default:
				fatalError("Unable to convert string to DNTangibility (\(str)).")
			}
		}
	}
	enum DNFunctionality {
		case Narrative
		case Mechanical
		
		var toString: String {
			switch self {
			case .Narrative:
				return "narrative"
			case .Mechanical:
				return "mechanical"
			}
		}
		
		static func fromString(_ str: String) -> DNFunctionality {
			switch str {
			case "narrative":
				return .Narrative
			case "mechanical":
				return .Mechanical
			default:
				fatalError("Unable to convert string to DNFunctionality (\(str)).")
			}
		}
	}
	enum DNClarity {
		case Explicit
		case Implicit
		
		var toString: String {
			switch self {
			case .Explicit:
				return "explicit"
			case .Implicit:
				return "implicit"
			}
		}
		
		static func fromString(_ str: String) -> DNClarity {
			switch str {
			case "explicit":
				return .Explicit
			case "implicit":
				return .Implicit
			default:
				fatalError("Unable to convert string to DNClarity (\(str)).")
			}
		}
	}
	enum DNDelivery {
		case Active
		case Passive
		
		var toString: String {
			switch self {
			case .Active:
				return "active"
			case .Passive:
				return "passive"
			}
		}
		
		static func fromString(_ str: String) -> DNDelivery {
			switch str {
			case "active":
				return .Active
			case "passive":
				return .Passive
			default:
				fatalError("Unable to convert string to DNDelivery (\(str)).")
			}
		}
	}
	
	var Tangibility: DNTangibility {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Tangibility changed (\(oldValue) -> \(Tangibility)).", level: .info)
			_story.Observers.forEach{$0.nvDNSequenceTangibilityDidChange(story: _story, sequence: self)}
		}
	}
	var Functionality: DNFunctionality {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Functionality changed (\(oldValue) -> \(Functionality)).", level: .info)
			_story.Observers.forEach{$0.nvDNSequenceFunctionalityDidChange(story: _story, sequence: self)}
		}
	}
	var Clarity: DNClarity {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Clarity changed (\(oldValue) -> \(Clarity)).", level: .info)
			_story.Observers.forEach{$0.nvDNSequenceClarityDidChange(story: _story, sequence: self)}
		}
	}
	var Delivery: DNDelivery {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Delivery changed (\(oldValue) -> \(Delivery)).", level: .info)
			_story.Observers.forEach{$0.nvDNSequenceDeliveryDidChange(story: _story, sequence: self)}
		}
	}
	
	override init(uuid: NSUUID, story: NVStory) {
		self.Tangibility = .Tangible
		self.Functionality = .Narrative
		self.Clarity = .Explicit
		self.Delivery = .Active
		super.init(uuid: uuid, story: story)
	}
}
