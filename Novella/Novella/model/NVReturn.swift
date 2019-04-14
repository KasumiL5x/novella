//
//  NVReturn.swift
//  novella
//
//  Created by Daniel Green on 14/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

class NVReturn: NVIdentifiable, NVLinkable {
	func canBecomeOrigin() -> Bool {
		return false
	}
	
	var UUID: NSUUID
	private let _story: NVStory
	
	var Label: String {
		didSet {
			NVLog.log("Return (\(UUID.uuidString)) Label changed (\(oldValue) -> \(Label)).", level: .info)
			_story.Observers.forEach{$0.nvReturnLabelDidChange(story: _story, rtrn: self)}
		}
	}
	
	var ExitFunction: NVFunction? {
		didSet {
			NVLog.log("Return (\(UUID.uuidString)) Exit Function changed (\(oldValue?.UUID.uuidString ?? "nil") -> \(ExitFunction?.UUID.uuidString ?? "nil")).", level: .info)
			_story.Observers.forEach{$0.nvReturnExitFunctionDidChange(story: _story, rtrn: self)}
		}
	}
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Label = ""
		self.ExitFunction = nil
	}
}

extension NVReturn: Equatable {
	static func == (lhs: NVReturn, rhs: NVReturn) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
