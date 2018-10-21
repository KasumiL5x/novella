//
//  NVLink.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVLink: NVIdentifiable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	
	// MARK: - Properties
	private(set) var Origin: NVLinkable
	private(set) var PreCondition: NVCondition
	private(set) var Transfer: NVTransfer
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory, origin: NVLinkable) {
		self.ID = id
		self._story = story
		self.Origin = origin
		self.PreCondition = NVCondition(story: story)
		self.Transfer = NVTransfer(story: story)
	}
}

extension NVLink: Equatable {
	static func ==(lhs: NVLink, rhs: NVLink) -> Bool {
		return lhs.ID == rhs.ID
	}
}
