//
//  NVVariable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVVariable {
	fileprivate let _uuid: NSUUID
	fileprivate var _name: String
	fileprivate var _synopsis: String
	fileprivate var _type: NVDataType
	fileprivate var _value: Any
	fileprivate var _initialValue: Any
	fileprivate var _constant: Bool
	internal var _folder: NVFolder?
	fileprivate let _storyManager: NVStoryManager
	
	init(uuid: NSUUID, name: String, type: NVDataType, storyManager: NVStoryManager) {
		self._uuid = uuid
		self._name = name
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._folder = nil
		self._storyManager = storyManager
	}
	
	public var Name: String {
		get{ return _name }
		set{
			_name = newValue
			_storyManager.Delegates.forEach{$0.onStoryVariableNameChanged(variable: self, name: _name)}
		}
	}
	public var Synopsis: String {
		get{ return _synopsis }
		set{
			_synopsis = newValue
			_storyManager.Delegates.forEach{$0.onStoryVariableSynopsisChanged(variable: self, synopsis: _synopsis)}
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
			_storyManager.Delegates.forEach{$0.onStoryVariableConstantChanged(variable: self, constant: _constant)}
		}
	}
	public var Folder: NVFolder? {
		get{ return _folder }
	}
	
	// MARK: Setters
	public func setType(_ type: NVDataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
		
		_storyManager.Delegates.forEach{$0.onStoryVariableTypeChanged(variable: self, type: _type)}
	}

	public func setValue(_ val: Any) {
		if self._constant {
			print("NVVariable::setValue(): Variable is constant.")
			return
		}
		if !_type.matches(value: val) {
			print("NVVariable::setValue(): Variable datatype mismatch (\(_type.stringValue) vs \(_type.stringValue)).")
			return
		}
		
		_value = val
		_storyManager.Delegates.forEach{$0.onStoryVariableValueChanged(variable: self, value: _value)}
	}
	
	public func setInitialValue(_ val: Any) {
		if !_type.matches(value: val) {
			print("NVVariable::setInitial(): Variable datatype mismatch (\(_type.stringValue) vs \(_type.stringValue)).")
			return
		}
		_initialValue = val
		_value = val
		_storyManager.Delegates.forEach{$0.onStoryVariableInitialValueChanged(variable: self, value: _initialValue)}
	}
}

// MARK: - NVIdentifiable -
extension NVVariable: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: - NVPathable -
extension NVVariable: NVPathable {
	public func localPath() -> String {
		return _name
	}
	
	public func parentPath() -> NVPathable? {
		return _folder
	}
}

// MARK: - Equatable -
extension NVVariable: Equatable {
	public static func == (lhs: NVVariable, rhs: NVVariable) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
