//
//  NVVariable.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVVariable: NVIdentifiable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	var _parent: NVFolder? // would make this private but swift doesn't support friend classes
	
	// MARK: - Properties
	var Name: String = "" {
		didSet {
			NVLog.log("Variable (\(ID)) renamed (\(oldValue)->\(Name)).", level: .info)
			_story.Delegates.forEach{$0.nvVariableDidRename(variable: self)}
		}
	}
	var Synopsis: String = "" {
		didSet {
			NVLog.log("Variable (\(ID)) synopsis set to \"\(Synopsis)\".", level: .info)
			_story.Delegates.forEach{$0.nvVariableSynopsisDidChange(variable: self)}
		}
	}
	var Constant: Bool = false {
		didSet {
			NVLog.log("Variable (\(ID)) constant changed to \(Constant).", level: .info)
			_story.Delegates.forEach{$0.nvVariableConstantDidChange(variable: self)}
		}
	}
	var Value: NVValue = NVValue(.boolean(false)) {
		didSet {
			if Constant {
				NVLog.log("Reverting Variable (\(ID)) value change as it is constant.", level: .warning)
				Value = oldValue
				return
			}
			NVLog.log("Variable (\(ID)) value changed to \(Value).", level: .info)
			_story.Delegates.forEach{$0.nvVariableValueDidChange(variable: self)}
		}
	}
	var InitialValue: NVValue = NVValue(.boolean(false)) {
		didSet {
			Value = InitialValue
			NVLog.log("Variable (\(ID)) initial value changed to \(InitialValue).", level: .info)
			_story.Delegates.forEach{$0.nvVariableInitialValueDidChange(variable: self)}
		}
	}
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory, name: String) {
		self.ID = id
		self._story = story
		self.Name = name
		_parent = nil
	}
}

extension NVVariable: NVPathable {
	func localPath() -> String {
		return Name
	}
	
	func parentPathable() -> NVPathable? {
		return _parent
	}
}

extension NVVariable: Equatable {
	static func ==(lhs: NVVariable, rhs: NVVariable) -> Bool {
		return lhs.ID == rhs.ID
	}
}
