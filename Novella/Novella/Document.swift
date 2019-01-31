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
		Story.addDelegate(self)
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
		let jsonString = "{}"
		guard let jsonData = jsonString.data(using: .utf8) else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		return jsonData
	}

	override func read(from data: Data, ofType typeName: String) throws {
	}
}

extension Document: NVStoryDelegate {
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
	
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
		updateChangeCount(.changeDone)
	}
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
		updateChangeCount(.changeDone)
	}
}
