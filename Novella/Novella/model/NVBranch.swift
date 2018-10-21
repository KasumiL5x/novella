//
//  NVBranch.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVBranch: NVIdentifiable, NVLinkable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	
	// MARK: - Properties
	private(set) var Condition: NVCondition
	private(set) var TrueTransfer: NVTransfer
	private(set) var FalseTransfer: NVTransfer
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory) {
		self.ID = id
		self._story = story
		self.Condition = NVCondition(story: story)
		self.TrueTransfer = NVTransfer(story: story)
		self.FalseTransfer = NVTransfer(story: story)
	}
	
	// MARK: - Evaluation
	func evaluate() -> NVTransfer {
		return Condition.evaluate() ? TrueTransfer : FalseTransfer
	}
}

extension NVBranch: Equatable {
	static func ==(lhs: NVBranch, rhs: NVBranch) -> Bool {
		return lhs.ID == rhs.ID
	}
}
