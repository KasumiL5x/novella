//
//  NVVariable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVVariable: NVObject {
	// MARK: - Variables -
	private var _synopsis: String
	private var _type: NVDataType
	private var _value: Any
	private var _initialValue: Any
	private var _constant: Bool
	internal var _folder: NVFolder?
	
	// MARK: - Properties -
	public var Synopsis: String {
		get{ return _synopsis }
		set{
			_synopsis = newValue
			
			NVLog.log("Variable (\(self.UUID)) synopsis set to (\(_synopsis)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryVariableSynopsisChanged(variable: self, synopsis: _synopsis)}
		}
	}
	public var DataType: NVDataType {
		get{ return _type }
	}
	public var Value: Any {
		get{ return _value }
	}
	public var InitialValue: Any {
		get{ return _initialValue }
	}
	public var IsConstant: Bool {
		get{ return _constant }
		set{
			_constant = newValue
			
			NVLog.log("Variable (\(self.UUID)) constant set to (\(_constant)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryVariableConstantChanged(variable: self, constant: _constant)}
		}
	}
	public var Folder: NVFolder? {
		get{ return _folder }
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager, uuid: NSUUID, name: String, type: NVDataType) {
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._folder = nil
		super.init(manager: manager, uuid: uuid)
		self.Name = name
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return false
	}
	
	// MARK: Setters
	public func setType(_ type: NVDataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		
		NVLog.log("Variable (\(self.UUID)) type set to (\(_type)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryVariableTypeChanged(variable: self, type: _type)}
	}

	@discardableResult
	public func setValue(_ val: Any) -> Bool {
		if self._constant {
			NVLog.log("Tried to set Variable's (\(self.UUID.uuidString)) value but it is constant.", level: .warning)
			return false
		}
		if !_type.matches(value: val) {
			NVLog.log("Tried to set Variable's (\(self.UUID.uuidString)) value but the datatype mismatched (expected \(_type.stringValue) but received \(type(of: val)).", level: .warning)
			return false
		}
		
		switch _type {
		case .boolean:
			_value = val as! Bool
		case .double:
			_value = val as! Double
		case .integer:
			_value = val as! Int
		}
		
		NVLog.log("Variable (\(self.UUID)) value set to (\(_value)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryVariableValueChanged(variable: self, value: _value)}
		return true
	}
	
	@discardableResult
	public func setInitialValue(_ val: Any) -> Bool {
		if !_type.matches(value: val) {
			NVLog.log("Tried to set Variable's (\(self.UUID.uuidString)) initial value but the datatype mismatched (expected \(_type.stringValue) but received \(type(of: val)).", level: .warning)
			return false
		}
		switch _type {
		case .boolean:
			_initialValue = val as! Bool
			_value = val as! Bool
		case .double:
			_initialValue = val as! Double
			_value = val as! Double
		case .integer:
			_initialValue = val as! Int
			_value = val as! Int
		}
		
		NVLog.log("Variable (\(self.UUID)) initial value set to (\(_initialValue)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryVariableInitialValueChanged(variable: self, value: _initialValue)}
		return true
	}
}

// MARK: - NVPathable -
extension NVVariable: NVPathable {
	public func localPath() -> String {
		return Name
	}
	
	public func parentPath() -> NVPathable? {
		return _folder
	}
}
