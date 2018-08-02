//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	static let EPSILON: Double = 0.001 // change to alter precision of double matching
	
	// MARK: - Variables -
	private var _variable: NVVariable?
	private var _defaultTransfer: NVTransfer
	private var _values: [AnyHashable:NVTransfer]
	
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
	public var Values: [AnyHashable:NVTransfer] {
		get{ return _values }
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVObject) {
		self._variable = nil
		self._defaultTransfer = NVTransfer(manager: manager)
		self._values = [:]
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	// MARK: - Functions -
	public func evaluate() -> NVTransfer {
		// no variable - default transfer
		guard let variable = _variable else {
			return _defaultTransfer
		}
		
		// switch values and return matching transfer
		for val in _values {
			// handle each data type separately as we can't directly compare Any/AnyHashable
			switch variable.DataType {
			case .boolean:
				// same data type
				if !(val.key is Bool) {
					break
				}
				if (val.key as! Bool) == (variable.Value as! Bool) {
					return val.value
				}
				
			case .integer:
				if !(val.key is Int) {
					break
				}
				if (val.key as! Int) == (variable.Value as! Int) {
					return val.value
				}
				
			case .double:
				if !(val.key is Double) {
					break
				}
				if fabs((val.key as! Double) - (variable.Value as! Double)) <= NVSwitch.EPSILON {
					return val.value
				}
			}
		}
		
		// nothing matched - return default
		return _defaultTransfer
	}
}
