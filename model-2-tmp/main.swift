//
//  main.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class DelegateImpl: NVStoryDelegate {
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
		
	}
	
	func nvStoryDidMakeBeat(story: NVStory, beat: NVBeat) {
		
	}
	
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
		
	}
	
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
		
	}
	
	func nvStoryDidMakeBeatLink(story: NVStory, link: NVBeatLink) {
		
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
		
	}
	
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
		
	}
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
		
	}
	
	func nvStoryDidDeleteBeat(story: NVStory, beat: NVBeat) {
		
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
		
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
		
	}
	
	func nvStoryDidDeleteBeatLink(story: NVStory, link: NVBeatLink) {
		
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
		
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
		
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup) {
		
	}
	
	func nvGroupDidAddBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		
	}
	
	func nvGroupDidRemoveBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		
	}
	
	func nvGroupDidAddBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		
	}
	
	func nvGroupDidRemoveBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		
	}
	
	func nvBeatLabelDidChange(story: NVStory, beat: NVBeat) {
		
	}
	
	func nvBeatParallelDidChange(story: NVStory, beat: NVBeat) {
		
	}
	
	func nvBeatEntryDidChange(story: NVStory, beat: NVBeat) {
		
	}
	
	func nvBeatDidAddEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		
	}
	
	func nvBeatDidRemoveEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		
	}
	
	func nvBeatDidAddEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		
	}
	
	func nvBeatDidRemoveEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		
	}
	
	func nvDNBeatTangibilityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		
	}
	
	func nvDNBeatFunctionalityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		
	}
	
	func nvDNBeatClarityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		
	}
	
	func nvDNBeatDeliveryDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		
	}
	
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
		
	}
	
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
		
	}
	
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
		
	}
	
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
		
	}
	
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable) {
		
	}
	
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable) {
		
	}
	
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable) {
		
	}
	
	func nvVariableInitialValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvBeatLinkDestinationDidChange(story: NVStory, link: NVBeatLink) {
	}
	
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink) {
	}
	
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
	}
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
	}
}


let story = NVStory()
story.Delegates.append(DelegateImpl())
//  __________________
// |    /2-3\         |
// | 0-1-----5---6-7  | b0
// |    \4------/     |
//  ------------------
let b0 = story.makeBeat()
let b0_evt = [story.makeEvent(),story.makeEvent(),story.makeEvent(),story.makeEvent(),story.makeEvent(),story.makeEvent(),story.makeEvent(),story.makeEvent()]
b0_evt.forEach{b0.add(event: $0)}
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[0], dest: b0_evt[1]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[1], dest: b0_evt[2]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[1], dest: b0_evt[4]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[2], dest: b0_evt[3]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[3], dest: b0_evt[5]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[5], dest: b0_evt[6]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[6], dest: b0_evt[7]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[4], dest: b0_evt[6]))
b0.add(eventLink: story.makeEventLink(uuid: NSUUID(), origin: b0_evt[1], dest: b0_evt[5]))
b0.Entry = b0_evt[0]
story.MainGroup.add(beat: b0)
story.MainGroup.Entry = b0

//b0.EventLinks[0].Destination = nil
//b0.EventLinks[0].Destination = b0.EventLinks[0].Origin

story.delete(beat: b0)
print("done")
