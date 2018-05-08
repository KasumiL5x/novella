//
//  Variable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVVariable {
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
	
	// MARK:  Getters
	var Name:         String   {get{ return _name }}
	var Synopsis:     String   {get{ return _synopsis }}
	var DataType:     NVDataType {get{ return _type }}
	var Value:        Any      {get{ return _value }}
	var InitialValue: Any      {get{ return _initialValue }}
	var IsConstant:   Bool     {get{ return _constant }}
	
	// MARK: Setters
	func setName(name: String) throws {
		// if not in a folder, name conflict doesn't matter
		if nil == _folder {
			_name = name
			return
		}
		// containing folder can't contain the requested name already
		if _folder!.containsVariableName(name: name) {
			throw NVError.nameTaken("Tried to change a Variable's name (\(_name)->\(name)) but it's folder (\(_folder!._name) already contains that.")
		}
		_name = name
	}
	
	func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	func setType(type: NVDataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
	}

	func setValue(val: Any) throws {
		if self._constant {
			throw NVError.isConstant("")
		}
		
		if !_type.matches(value: val) {
			throw NVError.dataTypeMismatch("")
		}
		
		_value = val
	}
	
	func setInitialValue(val: Any) throws {
		if !_type.matches(value: val) {
			throw NVError.dataTypeMismatch("")
		}
		_initialValue = val
		_value = val
	}
	
	func setConstant(const: Bool) {
		self._constant = const
	}
}

// MARK: Pathable
extension NVVariable: NVPathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> NVPathable? {
		return _folder
	}
}

// MARK: Identifiable
extension NVVariable: NVIdentifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVVariable: Equatable {
	static func == (lhs: NVVariable, rhs: NVVariable) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
