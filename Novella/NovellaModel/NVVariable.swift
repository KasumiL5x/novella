//
//  NVVariable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVVariable {
	let _uuid: NSUUID
	var _name: String
	var _synopsis: String
	var _type: NVDataType
	var _value: Any
	var _initialValue: Any
	var _constant: Bool
	var _folder: NVFolder?
	
	init(uuid: NSUUID, name: String, type: NVDataType) {
		self._uuid = uuid
		self._name = name
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._folder = nil
	}
	
	// MARK:  Properties
	public var Name: String {
		get{ return _name }
		set{
			_name = newValue
		}
	}
	public var Synopsis:     String     {get{ return _synopsis } set{ _synopsis = newValue }}
	public var DataType:     NVDataType {get{ return _type }}
	public var Value:        Any        {get{ return _value }}
	public var InitialValue: Any        {get{ return _initialValue }}
	public var IsConstant:   Bool       {get{ return _constant } set{ _constant = newValue }}
	public var Folder:       NVFolder?  {get{ return _folder }}
	
	// MARK: Setters
	public func setType(_ type: NVDataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
	}

	public func setValue(_ val: Any) throws {
		if self._constant {
			throw NVError.isConstant("")
		}
		
		if !_type.matches(value: val) {
			throw NVError.dataTypeMismatch("")
		}
		
		_value = val
	}
	
	public func setInitialValue(_ val: Any) throws {
		if !_type.matches(value: val) {
			throw NVError.dataTypeMismatch("")
		}
		_initialValue = val
		_value = val
	}
}

// MARK: NVIdentifiable
extension NVVariable: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: NVPathable
extension NVVariable: NVPathable {
	public func localPath() -> String {
		return _name
	}
	
	public func parentPath() -> NVPathable? {
		return _folder
	}
}

// MARK: Equatable
extension NVVariable: Equatable {
	public static func == (lhs: NVVariable, rhs: NVVariable) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
