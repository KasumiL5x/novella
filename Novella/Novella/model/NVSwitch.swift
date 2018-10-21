//
//  NVSwitch.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVSwitchOption: Equatable {
	private var id = NSUUID() // used for matching
	var value: NVValue
	var transfer: NVTransfer
	
	init(story: NVStory) {
		value = NVValue(.boolean(false))
		transfer = NVTransfer(story: story)
	}
	
	static func == (lhs: NVSwitchOption, rhs: NVSwitchOption) -> Bool {
		return lhs.id == rhs.id
	}
}

class NVSwitch: NVIdentifiable, NVLinkable {
	static let EPSILON: Double = 0.001
	
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	
	// MARK: - Properties
	var Variable: NVVariable? = nil {
		didSet {
			NVLog.log("Switch (\(ID)) variable changed to (\(Variable?.ID.uuidString ?? "nil")).", level: .info)
			_story.Delegates.forEach{$0.nvSwitchVariableDidChange(swtch: self)}
		}
	}
	private(set) var DefaultOption: NVSwitchOption
	private(set) var Options: [NVSwitchOption] = []
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory) {
		self.ID = id
		self._story = story
		self.DefaultOption = NVSwitchOption(story: story)
	}
	
	// MARK: - Options
	@discardableResult
	func addOption() -> NVSwitchOption {
		return addOption(withValue: NVValue(.boolean(false)))
	}
	@discardableResult
	func addOption(withValue: NVValue) -> NVSwitchOption {
		let opt = NVSwitchOption(story: _story)
		opt.value = withValue
		Options.append(opt)
		
		NVLog.log("Added option to Switch (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvSwitchDidAddOption(swtch: self, option: opt)}
		return opt
	}
	func removeOption(option: NVSwitchOption) {
		if let idx = Options.index(of: option) {
			Options.remove(at: idx)
			NVLog.log("Removed option to Switch (\(ID)).", level: .info)
			_story.Delegates.forEach{$0.nvSwitchDidRemoveOption(swtch: self, option: option)}
		}
	}
	
	// MARK: - Evaluation
	func evaluate() -> NVTransfer {
		guard let variable = Variable else {
			return DefaultOption.transfer // no variable
		}
		
		// look for match by (raw) value
		for opt in Options {
			if opt.value.Raw.type != variable.Value.Raw.type { // don't check mismatched type
				continue
			}
			if variable.Value.Raw.isEqualTo(opt.value.Raw) { // check actual value
				return opt.transfer
			}
		}
		
		// no match
		return DefaultOption.transfer
	}
	
}

extension NVSwitch: Equatable {
	static func ==(lhs: NVSwitch, rhs: NVSwitch) -> Bool {
		return lhs.ID == rhs.ID
	}
}
