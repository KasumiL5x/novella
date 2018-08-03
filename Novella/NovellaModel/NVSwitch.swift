//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitchOption: Equatable {
	private var _owner: NVSwitch
	private var _manager: NVStoryManager
	private var _value: Any
	private var _transfer: NVTransfer
	private var _id: Int
	
	public var Value: Any {
		get{ return _value }
		set{
			_value = newValue
			
			NVLog.log("Switch's (\(_owner.UUID.uuidString)) option (ID: \(_id)) value changed to (\(_value)).", level: .info)
			_manager.Delegates.forEach{$0.onStorySwitchOptionValueChanged(swtch: _owner, option: self)}
		}
	}
	public var Transfer: NVTransfer {
		get{ return _transfer }
	}
	public var ID: Int {
		get{ return _id }
	}
	
	public init(owner: NVSwitch, manager: NVStoryManager, id: Int) {
		self._owner = owner
		self._manager = manager
		self._value = 0
		self._transfer = NVTransfer(manager: manager)
		self._id = id
	}
	
	public static func == (lhs: NVSwitchOption, rhs: NVSwitchOption) -> Bool {
		return (lhs._owner == rhs._owner) && (lhs._id == rhs._id)
	}
}

public class NVSwitch : NVBaseLink {
	static let EPSILON: Double = 0.001 // change to alter precision of double matching
	
	// MARK: - Variables -
	private var _variable: NVVariable?
	private var _defaultTransfer: NVTransfer
	private var _options: [NVSwitchOption]
	private var _uniqueID: Int
	
	// MARK: - Properties -
	public var Variable: NVVariable? {
		get{ return _variable }
		set{
			_variable = newValue
			
			NVLog.log("Switch's (\(self.UUID.uuidString)) variable set to (\(_variable?.UUID.uuidString ?? "nil")).", level: .info)
			_manager.Delegates.forEach{$0.onStorySwitchVariableChanged(swtch: self, variable: _variable)}
		}
	}
	public var DefaultTransfer: NVTransfer {
		get{  return _defaultTransfer }
	}
	public var Options: [NVSwitchOption] {
		get{ return _options }
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		self._variable = nil
		self._defaultTransfer = NVTransfer(manager: manager)
		self._options = []
		self._uniqueID = 0
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	// MARK: - Functions -
	func addOption() -> NVSwitchOption {
		let opt = NVSwitchOption(owner: self, manager: _manager, id: _uniqueID)
		_options.append(opt)
		_uniqueID += 1
		
		NVLog.log("Option (ID: \(opt.ID)) added to Switch (\(self.UUID.uuidString)).", level: .info)
		_manager.Delegates.forEach{$0.onStorySwitchOptionAdded(swtch: self, option: opt)}
		return opt
	}
	
	func removeOption(_ opt: NVSwitchOption) {
		guard let idx = _options.index(of: opt) else {
			return
		}
		_options.remove(at: idx)
		
		NVLog.log("Option (ID: \(opt.ID)) removed from Switch (\(self.UUID.uuidString)).", level: .info)
		_manager.Delegates.forEach{$0.onStorySwitchOptionRemoved(swtch: self, option: opt)}
	}
	
	public func evaluate() -> NVTransfer {
		// no variable - default transfer
		guard let variable = _variable else {
			return _defaultTransfer
		}
		
		// switch options and return matching transfer
		for opt in _options {
			// handle each data type separately as we can't directly compare Any/AnyHashable
			switch variable.DataType {
			case .boolean:
				// same data type
				if !(opt.Value is Bool) {
					break
				}
				if (opt.Value as! Bool) == (variable.Value as! Bool) {
					return opt.Transfer
				}
				
			case .integer:
				if !(opt.Value is Int) {
					break
				}
				if (opt.Value as! Int) == (variable.Value as! Int) {
					return opt.Transfer
				}
				
			case .double:
				if !(opt.Value is Double) {
					break
				}
				if fabs((opt.Value as! Double) - (variable.Value as! Double)) <= NVSwitch.EPSILON {
					return opt.Transfer
				}
			}
		}
		
		// nothing matched - return default
		return _defaultTransfer
	}
}
