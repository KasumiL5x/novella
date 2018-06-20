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
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
		
		_manager.Delegates.forEach{$0.onStoryVariableTypeChanged(variable: self, type: _type)}
	}

	@discardableResult
	public func setValue(_ val: Any) -> Bool {
		if self._constant {
			print("NVVariable::setValue(): Variable is constant.")
			return false
		}
		if !_type.matches(value: val) {
			print("NVVariable::setValue(): Variable datatype mismatch (expected \(_type.stringValue), received \(type(of: val))).")
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
		_manager.Delegates.forEach{$0.onStoryVariableValueChanged(variable: self, value: _value)}
		return true
	}
	
	@discardableResult
	public func setInitialValue(_ val: Any) -> Bool {
		if !_type.matches(value: val) {
			print("NVVariable::setInitial(): Variable datatype mismatch (expected \(_type.stringValue), received \(type(of: val))).")
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
