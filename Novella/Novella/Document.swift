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
	
	func nvStoryDidMakeBeat(story: NVStory, beat: NVBeat) {
		updateChangeCount(.changeDone)
		if Positions[beat.UUID] == nil {
			Positions[beat.UUID] = CGPoint.zero
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
	
	func nvStoryDidMakeBeatLink(story: NVStory, link: NVBeatLink) {
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
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteBeat(story: NVStory, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteBeatLink(story: NVStory, link: NVBeatLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidAddBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvGroupDidRemoveBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatLabelDidChange(story: NVStory, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatParallelDidChange(story: NVStory, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatEntryDidChange(story: NVStory, beat: NVBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatDidAddEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatDidRemoveEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatDidAddEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvBeatDidRemoveEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNBeatTangibilityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNBeatFunctionalityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNBeatClarityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
		updateChangeCount(.changeDone)
	}
	
	func nvDNBeatDeliveryDidChange(story: NVStory, beat: NVDiscoverableBeat) {
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
	
	func nvBeatLinkDestinationDidChange(story: NVStory, link: NVBeatLink) {
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
