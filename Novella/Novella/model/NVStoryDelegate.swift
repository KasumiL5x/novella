//
//  NVStoryDelegate.swift
//  novella
//
//  Created by dgreen on 04/12/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

protocol NVStoryDelegate: AnyObject {
	// creation
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup)
	func nvStoryDidMakeBeat(story: NVStory, beat: NVBeat)
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent)
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity)
	func nvStoryDidMakeBeatLink(story: NVStory, link: NVBeatLink)
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink)
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction)
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition)
	
	// deletion
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup)
	func nvStoryDidDeleteBeat(story: NVStory, beat: NVBeat)
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent)
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity)
	func nvStoryDidDeleteBeatLink(story: NVStory, link: NVBeatLink)
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink)
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction)
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition)
	
	// groups
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup)
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVBeat?, newEntry: NVBeat?)
	func nvGroupDidAddBeat(story: NVStory, group: NVGroup, beat: NVBeat)
	func nvGroupDidRemoveBeat(story: NVStory, group: NVGroup, beat: NVBeat)
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidAddBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink)
	func nvGroupDidRemoveBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink)
	
	// beats
	func nvBeatLabelDidChange(story: NVStory, beat: NVBeat)
	func nvBeatParallelDidChange(story: NVStory, beat: NVBeat)
	func nvBeatEntryDidChange(story: NVStory, beat: NVBeat, oldEntry: NVEvent?, newEntry: NVEvent?)
	func nvBeatDidAddEvent(story: NVStory, beat: NVBeat, event: NVEvent)
	func nvBeatDidRemoveEvent(story: NVStory, beat: NVBeat, event: NVEvent)
	func nvBeatDidAddEventLink(story: NVStory, beat: NVBeat, link: NVEventLink)
	func nvBeatDidRemoveEventLink(story: NVStory, beat: NVBeat, link: NVEventLink)
	
	// discoverable beat
	func nvDNBeatTangibilityDidChange(story: NVStory, beat: NVDiscoverableBeat)
	func nvDNBeatFunctionalityDidChange(story: NVStory, beat: NVDiscoverableBeat)
	func nvDNBeatClarityDidChange(story: NVStory, beat: NVDiscoverableBeat)
	func nvDNBeatDeliveryDidChange(story: NVStory, beat: NVDiscoverableBeat)
	
	// event
	func nvEventLabelDidChange(story: NVStory, event: NVEvent)
	func nvEventParallelDidChange(story: NVStory, event: NVEvent)
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity)
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity)
	
	// variables
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable)
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable)
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable)
	func nvVariableInitialValueDidChange(story: NVStory, variable: NVVariable)
	
	// links
	func nvBeatLinkDestinationDidChange(story: NVStory, link: NVBeatLink)
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink)
	
	// entities
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity)
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity)
	
	// function
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction)
	
	// conditions
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition)
}

// default implementation
extension NVStoryDelegate {
}
