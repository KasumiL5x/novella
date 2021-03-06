//
//  NVVariable.swift
//  novella
//
//  Created by Daniel Green on 02/12/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVVariable: NVIdentifiable {
	var UUID: NSUUID
	private let _story: NVStory
	var Name: String {
		didSet {
			NVLog.log("Variable (\(UUID.uuidString)) Name changed (\(oldValue) -> \(Name)).", level: .info)
			_story.Observers.forEach{$0.nvVariableNameDidChange(story: _story, variable: self)}
		}
	}
	var Constant: Bool {
		didSet {
			NVLog.log("Variable (\(UUID.uuidString)) Constant changed (\(oldValue) -> \(Constant)).", level: .info)
			_story.Observers.forEach{$0.nvVariableConstantDidChange(story: _story, variable: self)}
		}
	}
	private(set) var Value: NVValue
	
	init(uuid: NSUUID, story: NVStory) {
		self.UUID = uuid
		self._story = story
		self.Name = ""
		self.Constant = false
		self.Value = NVValue(.boolean(false))
	}
	
	func set(value: NVValue) {
		if Constant {
			NVLog.log("Tried to set Variable (\(UUID.uuidString)) Value but it was constant.", level: .warning)
			return
		}
		
		let oldValue = self.Value
		self.Value = value
		NVLog.log("Variable (\(UUID.uuidString)) Value changed (\(oldValue) -> \(value)).", level: .info)
		_story.Observers.forEach{$0.nvVariableValueDidChange(story: _story, variable: self)}
	}
}

extension NVVariable: Equatable {
	static func == (lhs: NVVariable, rhs: NVVariable) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
