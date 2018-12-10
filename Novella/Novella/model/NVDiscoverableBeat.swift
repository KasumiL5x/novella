//
//  NVDiscoverableBeat.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVDiscoverableBeat: NVBeat {
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
			NVLog.log("DNBeat (\(UUID.uuidString)) Tangibility changed (\(oldValue) -> \(Tangibility)).", level: .info)
			_story.Delegates.forEach{$0.nvDNBeatTangibilityDidChange(story: _story, beat: self)}
		}
	}
	var Functionality: DNFunctionality {
		didSet {
			NVLog.log("DNBeat (\(UUID.uuidString)) Functionality changed (\(oldValue) -> \(Functionality)).", level: .info)
			_story.Delegates.forEach{$0.nvDNBeatFunctionalityDidChange(story: _story, beat: self)}
		}
	}
	var Clarity: DNClarity {
		didSet {
			NVLog.log("DNBeat (\(UUID.uuidString)) Clarity changed (\(oldValue) -> \(Clarity)).", level: .info)
			_story.Delegates.forEach{$0.nvDNBeatClarityDidChange(story: _story, beat: self)}
		}
	}
	var Delivery: DNDelivery {
		didSet {
			NVLog.log("DNBeat (\(UUID.uuidString)) Delivery changed (\(oldValue) -> \(Delivery)).", level: .info)
			_story.Delegates.forEach{$0.nvDNBeatDeliveryDidChange(story: _story, beat: self)}
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
