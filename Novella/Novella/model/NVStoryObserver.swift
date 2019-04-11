//
//  NVStoryObserver.swift
//  novella
//
//  Created by Daniel Green on 21/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

protocol NVStoryObserver: class {
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
	func nvStoryDidMakeSelector(story: NVStory, selector: NVSelector)
	
	// pre-deletion
	func nvStoryWillDeleteGroup(story: NVStory, group: NVGroup)
	func nvStoryWillDeleteSequence(story: NVStory, sequence: NVSequence)
	func nvStoryWillDeleteEvent(story: NVStory, event: NVEvent)
	func nvStoryWillDeleteEntity(story: NVStory, entity: NVEntity)
	func nvStoryWillDeleteSequenceLink(story: NVStory, link: NVSequenceLink)
	func nvStoryWillDeleteEventLink(story: NVStory, link: NVEventLink)
	func nvStoryWillDeleteVariable(story: NVStory, variable: NVVariable)
	func nvStoryWillDeleteFunction(story: NVStory, function: NVFunction)
	func nvStoryWillDeleteCondition(story: NVStory, condition: NVCondition)
	func nvStoryWillDeleteSelector(story: NVStory, selector: NVSelector)
	
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
	func nvStoryDidDeleteSelector(story: NVStory, selector: NVSelector)
	
	// groups
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup)
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?)
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink)
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink)
	func nvGroupTopmostDidChange(story: NVStory, group: NVGroup)
	func nvGroupMaxActivationsDidChange(story: NVStory, group: NVGroup)
	func nvGroupKeepAliveDidChange(story: NVStory, group: NVGroup)
	func nvGroupConditionDidChange(story: NVStory, group: NVGroup)
	func nvGroupEntryFunctionDidChange(story: NVStory, group: NVGroup)
	func nvGroupExitFunctionDidChange(story: NVStory, group: NVGroup)
	func nvGroupAttributesDidChange(story: NVStory, group: NVGroup)
	
	// sequences
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceParallelDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceEntryDidChange(story: NVStory, sequence: NVSequence, oldEntry: NVEvent?, newEntry: NVEvent?)
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent)
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent)
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink)
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink)
	func nvSequenceTopmostDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceMaxActivationsDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceKeepAliveDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceConditionDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceEntryFunctionDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceExitFunctionDidChange(story: NVStory, sequence: NVSequence)
	func nvSequenceAttributesDidChange(story: NVStory, sequence: NVSequence)
	
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
	func nvEventTopmostDidChange(story: NVStory, event: NVEvent)
	func nvEventMaxActivationsDidChange(story: NVStory, event: NVEvent)
	func nvEventKeepAliveDidChange(story: NVStory, event: NVEvent)
	func nvEventConditionDidChange(story: NVStory, event: NVEvent)
	func nvEventEntryFunctionDidChange(story: NVStory, event: NVEvent)
	func nvEventDoFunctionDidChange(story: NVStory, event: NVEvent)
	func nvEventExitFunctionDidChange(story: NVStory, event: NVEvent)
	func nvEventInstigatorsDidChange(story: NVStory, event: NVEvent)
	func nvEventTargetsDidChange(story: NVStory, event: NVEvent)
	func nvEventAttributesDidChange(story: NVStory, event: NVEvent)
	
	// variables
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable)
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable)
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable)
	
	// links
	func nvSequenceLinkDestinationDidChange(story: NVStory, link: NVSequenceLink)
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink)
	
	// entities
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity)
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity)
	func nvEntityTagsDidChange(story: NVStory, entity: NVEntity)
	
	// functions
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction)
	func nvFunctionLabelDidChange(story: NVStory, function: NVFunction)
	
	// conditions
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition)
	func nvConditionLabelDidChange(story: NVStory, condition: NVCondition)
	
	// selectors
	func nvSelectorCodeDidChange(story: NVStory, selector: NVSelector)
	func nvSelectorLabelDidChange(story: NVStory, selector: NVSelector)
}

// default implementations
extension NVStoryObserver {
	// creation
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
	}
	func nvStoryDidMakeSequence(story: NVStory, sequence: NVSequence) {
	}
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
	}
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
	}
	func nvStoryDidMakeSequenceLink(story: NVStory, link: NVSequenceLink) {
	}
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
	}
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryDidMakeSelector(story: NVStory, selector: NVSelector) {
	}
	
	// pre-deletion
	func nvStoryWillDeleteGroup(story: NVStory, group: NVGroup) {
	}
	func nvStoryWillDeleteSequence(story: NVStory, sequence: NVSequence) {
	}
	func nvStoryWillDeleteEvent(story: NVStory, event: NVEvent) {
	}
	func nvStoryWillDeleteEntity(story: NVStory, entity: NVEntity) {
	}
	func nvStoryWillDeleteSequenceLink(story: NVStory, link: NVSequenceLink) {
	}
	func nvStoryWillDeleteEventLink(story: NVStory, link: NVEventLink) {
	}
	func nvStoryWillDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryWillDeleteFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryWillDeleteCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryWillDeleteSelector(story: NVStory, selector: NVSelector) {
	}
	
	// deletion
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
	}
	func nvStoryDidDeleteSequence(story: NVStory, sequence: NVSequence) {
	}
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
	}
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
	}
	func nvStoryDidDeleteSequenceLink(story: NVStory, link: NVSequenceLink) {
	}
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
	}
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryDidDeleteSelector(story: NVStory, selector: NVSelector) {
	}
	
	// groups
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?) {
	}
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
	}
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
	}
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
	}
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
	}
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
	}
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
	}
	func nvGroupTopmostDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupMaxActivationsDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupKeepAliveDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupConditionDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupEntryFunctionDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupExitFunctionDidChange(story: NVStory, group: NVGroup) {
	}
	func nvGroupAttributesDidChange(story: NVStory, group: NVGroup) {
	}
	
	// sequences
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceParallelDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceEntryDidChange(story: NVStory, sequence: NVSequence, oldEntry: NVEvent?, newEntry: NVEvent?) {
	}
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
	}
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
	}
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
	}
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
	}
	func nvSequenceTopmostDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceMaxActivationsDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceKeepAliveDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceConditionDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceEntryFunctionDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceExitFunctionDidChange(story: NVStory, sequence: NVSequence) {
	}
	func nvSequenceAttributesDidChange(story: NVStory, sequence: NVSequence) {
	}
	
	// discoverable sequence
	func nvDNSequenceTangibilityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceFunctionalityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceClarityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceDeliveryDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	// event
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	func nvEventTopmostDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventMaxActivationsDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventKeepAliveDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventConditionDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventEntryFunctionDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventDoFunctionDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventExitFunctionDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventInstigatorsDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventTargetsDidChange(story: NVStory, event: NVEvent) {
	}
	func nvEventAttributesDidChange(story: NVStory, event: NVEvent) {
	}
	
	// variables
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable) {
	}
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable) {
	}
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	// links
	func nvSequenceLinkDestinationDidChange(story: NVStory, link: NVSequenceLink) {
	}
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink) {
	}
	
	// entities
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity) {
	}
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity) {
	}
	func nvEntityTagsDidChange(story: NVStory, entity: NVEntity) {
	}
	
	// functions
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
	}
	func nvFunctionLabelDidChange(story: NVStory, function: NVFunction) {
	}
	
	// conditions
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
	}
	func nvConditionLabelDidChange(story: NVStory, condition: NVCondition) {
	}
	
	// selectors
	func nvSelectorCodeDidChange(story: NVStory, selector: NVSelector) {
	}
	func nvSelectorLabelDidChange(story: NVStory, selector: NVSelector) {
	}
}
