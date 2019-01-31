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
	func nvStoryDidMakeSequence(story: NVStory, sequence: NVSequence)
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent)
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity)
	func nvStoryDidMakeSequenceLink(story: NVStory, link: NVSequenceLink)
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink)
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction)
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition)
	
	// deletion
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup)
	func nvStoryDidDeleteSequence(story: NVStory, sequence: NVSequence)
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent)
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity)
	func nvStoryDidDeleteSequenceLink(story: NVStory, link: NVSequenceLink)
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink)
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction)
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition)
	
	// groups
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup)
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?)
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink)
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink)
	
	// sequences
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceParallelDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceEntryDidChange(story: NVStory, sequence: NVSequence, oldEntry: NVEvent?, newEntry: NVEvent?)
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent)
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent)
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink)
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink)
	
	// discoverable sequence
	func nvDNSequenceTangibilityDidChange(story: NVStory, sequence: NVDiscoverableSequence)
	func nvDNSequenceFunctionalityDidChange(story: NVStory, sequence: NVDiscoverableSequence)
	func nvDNSequenceClarityDidChange(story: NVStory, sequence: NVDiscoverableSequence)
	func nvDNSequenceDeliveryDidChange(story: NVStory, sequence: NVDiscoverableSequence)
	
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
	func nvSequenceLinkDestinationDidChange(story: NVStory, link: NVSequenceLink)
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
