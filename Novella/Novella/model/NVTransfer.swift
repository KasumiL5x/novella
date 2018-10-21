//
//  NVTransfer.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVTransfer {
	// MARK: - Variables
	private let _story: NVStory
	
	// MARK: - Properties
	var Destination: NVLinkable? = nil {
		didSet {
			NVLog.log("Transfer's destination set to (\(Destination?.ID.uuidString ?? "nil")).", level: .info)
			_story.Delegates.forEach{$0.nvTransferDestinationDidSet(transfer: self)}
		}
	}
	private(set) var Function: NVFunction
	
	// MARK: - Initialization
	init(story: NVStory) {
		self._story = story
		self.Function = NVFunction(story: story)
	}
}
