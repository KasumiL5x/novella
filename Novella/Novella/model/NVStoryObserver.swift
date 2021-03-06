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
	func nvStoryDidMakeLink(story: NVStory, link: NVLink)
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction)
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition)
	func nvStoryDidMakeSelector(story: NVStory, selector: NVSelector)
	func nvStoryDidMakeHub(story: NVStory, hub: NVHub)
	func nvStoryDidMakeReturn(story: NVStory, rtrn: NVReturn)
	
	// pre-deletion
	func nvStoryWillDeleteGroup(story: NVStory, group: NVGroup)
	func nvStoryWillDeleteSequence(story: NVStory, sequence: NVSequence)
	func nvStoryWillDeleteEvent(story: NVStory, event: NVEvent)
	func nvStoryWillDeleteEntity(story: NVStory, entity: NVEntity)
	func nvStoryWillDeleteLink(story: NVStory, link: NVLink)
	func nvStoryWillDeleteVariable(story: NVStory, variable: NVVariable)
	func nvStoryWillDeleteFunction(story: NVStory, function: NVFunction)
	func nvStoryWillDeleteCondition(story: NVStory, condition: NVCondition)
	func nvStoryWillDeleteSelector(story: NVStory, selector: NVSelector)
	func nvStoryWillDeleteHub(story: NVStory, hub: NVHub)
	func nvStoryWillDeleteReturn(story: NVStory, rtrn: NVReturn)
	
	// deletion
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup)
	func nvStoryDidDeleteSequence(story: NVStory, sequence: NVSequence)
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent)
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity)
	func nvStoryDidDeleteLink(story: NVStory, link: NVLink)
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable)
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction)
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition)
	func nvStoryDidDeleteSelector(story: NVStory, selector: NVSelector)
	func nvStoryDidDeleteHub(story: NVStory, hub: NVHub)
	func nvStoryDidDeleteReturn(story: NVStory, rtrn: NVReturn)
	
	// groups
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup)
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?)
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence)
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup)
	func nvGroupDidAddLink(story: NVStory, group: NVGroup, link: NVLink)
	func nvGroupDidRemoveLink(story: NVStory, group: NVGroup, link: NVLink)
	func nvGroupDidAddHub(story: NVStory, group: NVGroup, hub: NVHub)
	func nvGroupDidRemoveHub(story: NVStory, group: NVGroup, hub: NVHub)
	func nvGroupDidAddReturn(story: NVStory, group: NVGroup, rtrn: NVReturn)
	func nvGroupDidRemoveReturn(story: NVStory, group: NVGroup, rtrn: NVReturn)
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
	func nvSequenceDidAddLink(story: NVStory, sequence: NVSequence, link: NVLink)
	func nvSequenceDidRemoveLink(story: NVStory, sequence: NVSequence, link: NVLink)
	func nvSequenceDidAddHub(story: NVStory, sequence: NVSequence, hub: NVHub)
	func nvSequenceDidRemoveHub(story: NVStory, sequence: NVSequence, hub: NVHub)
	func nvSequenceDidAddReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn)
	func nvSequenceDidRemoveReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn)
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
	func nvLinkDestinationChanged(story: NVStory, link: NVLink)
	
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
	
	// hubs
	func nvHubLabelDidChange(story: NVStory, hub: NVHub)
	func nvHubConditionDidChange(story: NVStory, hub: NVHub)
	func nvHubEntryFunctionDidChange(story: NVStory, hub: NVHub)
	func nvHubReturnFunctionDidChange(story: NVStory, hub: NVHub)
	func nvHubExitFunctionDidChange(story: NVStory, hub: NVHub)
	
	// returns
	func nvReturnLabelDidChange(story: NVStory, rtrn: NVReturn)
	func nvReturnExitFunctionDidChange(story: NVStory, rtrn: NVReturn)
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
	func nvStoryDidMakeLink(story: NVStory, link: NVLink) {
	}
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryDidMakeSelector(story: NVStory, selector: NVSelector) {
	}
	func nvStoryDidMakeHub(story: NVStory, hub: NVHub) {
	}
	func nvStoryDidMakeReturn(story: NVStory, rtrn: NVReturn) {
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
	func nvStoryWillDeleteLink(story: NVStory, link: NVLink) {
	}
	func nvStoryWillDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryWillDeleteFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryWillDeleteCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryWillDeleteSelector(story: NVStory, selector: NVSelector) {
	}
	func nvStoryWillDeleteHub(story: NVStory, hub: NVHub) {
	}
	func nvStoryWillDeleteReturn(story: NVStory, rtrn: NVReturn) {
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
	func nvStoryDidDeleteLink(story: NVStory, link: NVLink) {
	}
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction) {
	}
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition) {
	}
	func nvStoryDidDeleteSelector(story: NVStory, selector: NVSelector) {
	}
	func nvStoryDidDeleteHub(story: NVStory, hub: NVHub) {
	}
	func nvStoryDidDeleteReturn(story: NVStory, rtrn: NVReturn) {
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
	func nvGroupDidAddLink(story: NVStory, group: NVGroup, link: NVLink) {
	}
	func nvGroupDidRemoveLink(story: NVStory, group: NVGroup, link: NVLink) {
	}
	func nvGroupDidAddHub(story: NVStory, group: NVGroup, hub: NVHub) {
	}
	func nvGroupDidRemoveHub(story: NVStory, group: NVGroup, hub: NVHub) {
	}
	func nvGroupDidAddReturn(story: NVStory, group: NVGroup, rtrn: NVReturn) {
	}
	func nvGroupDidRemoveReturn(story: NVStory, group: NVGroup, rtrn: NVReturn) {
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
	func nvSequenceDidAddLink(story: NVStory, sequence: NVSequence, link: NVLink) {
	}
	func nvSequenceDidRemoveLink(story: NVStory, sequence: NVSequence, link: NVLink) {
	}
	func nvSequenceDidAddHub(story: NVStory, sequence: NVSequence, hub: NVHub) {
	}
	func nvSequenceDidRemoveHub(story: NVStory, sequence: NVSequence, hub: NVHub) {
	}
	func nvSequenceDidAddReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn) {
	}
	func nvSequenceDidRemoveReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn) {
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
	
	// discoverable sequences
	func nvDNSequenceTangibilityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceFunctionalityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceClarityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	func nvDNSequenceDeliveryDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	// events
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
	func nvLinkDestinationChanged(story: NVStory, link: NVLink) {
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
	
	// hubs
	func nvHubLabelDidChange(story: NVStory, hub: NVHub) {
	}
	func nvHubConditionDidChange(story: NVStory, hub: NVHub) {
	}
	func nvHubEntryFunctionDidChange(story: NVStory, hub: NVHub) {
	}
	func nvHubReturnFunctionDidChange(story: NVStory, hub: NVHub) {
	}
	func nvHubExitFunctionDidChange(story: NVStory, hub: NVHub) {
	}
	
	// returns
	func nvReturnLabelDidChange(story: NVStory, rtrn: NVReturn) {
	}
	func nvReturnExitFunctionDidChange(story: NVStory, rtrn: NVReturn) {
	}
}
