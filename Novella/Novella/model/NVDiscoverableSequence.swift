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
	}
	enum DNFunctionality {
		case Narrative
		case Mechanical
	}
	enum DNClarity {
		case Explicit
		case Implicit
	}
	enum DNDelivery {
		case Active
		case Passive
	}
	
	var Tangibility: DNTangibility {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Tangibility changed (\(oldValue) -> \(Tangibility)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvDNSequenceTangibilityDidChange(story: _story, sequence: self)}
		}
	}
	var Functionality: DNFunctionality {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Functionality changed (\(oldValue) -> \(Functionality)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvDNSequenceFunctionalityDidChange(story: _story, sequence: self)}
		}
	}
	var Clarity: DNClarity {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Clarity changed (\(oldValue) -> \(Clarity)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvDNSequenceClarityDidChange(story: _story, sequence: self)}
		}
	}
	var Delivery: DNDelivery {
		didSet {
			NVLog.log("DNSequence (\(UUID.uuidString)) Delivery changed (\(oldValue) -> \(Delivery)).", level: .info)
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvDNSequenceDeliveryDidChange(story: _story, sequence: self)}
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
