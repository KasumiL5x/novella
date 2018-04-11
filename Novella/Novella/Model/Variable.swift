//
//  Variable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Variable {
	var _name: String
	var _synopsis: String
	var _type: DataType
	var _value: Any
	var _initialValue: Any
	var _constant: Bool
	var _set: VariableSet? // internal only
	
	init(name: String, type: DataType) {
		self._name = name
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._set = nil
	}
	
	// MARK:  Getters
	var Name:         String   {get{ return _name }}
	var Synopsis:     String   {get{ return _synopsis }}
	var DataType:     DataType {get{ return _type }}
	var Value:        Any      {get{ return _value }}
	var InitialValue: Any      {get{ return _initialValue }}
	var IsConstant:   Bool     {get{ return _constant }}
	
	// MARK: Setters
	func setName(name: String) throws {
		// if not in a set, name conflict doesn't matter
		if nil == _set {
			_name = name
			return
		}
		
		// containing set can't contain the requested name already
		if _set!.containsVariable(name: name) {
			throw Errors.nameAlreadyTaken("Tried to change Variable \(_name) to \(name), but its set (\(_set!.Name) already contains that name.")
		}
		_name = name
	}
	
	func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	func setType(type: DataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
	}

	func setValue(val: Any) throws {
		if self._constant {
			throw Errors.isConstant("")
		}
		
		if !_type.matches(value: val) {
			throw Errors.dataTypeMismatch("")
		}
		
		_value = val
	}
	
	func setInitialValue(val: Any) throws {
		if !_type.matches(value: val) {
			throw Errors.dataTypeMismatch("")
		}
		_initialValue = val
		_value = val
	}
	
	func setConstant(const: Bool) {
		self._constant = const
	}
}
