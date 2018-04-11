//
//  Variable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class Variable {
	var _name: String
	var _synopsis: String
	var _type: DataType
	var _value: Any
	var _initialValue: Any
	var _constant: Bool
	var _set: VariableSet? // internal only
	
	public init(name: String, type: DataType) {
		self._name = name
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._set = nil
	}
	
	// MARK:  Getters
	public var Name:         String   {get{ return _name }}
	public var Synopsis:     String   {get{ return _synopsis }}
	public var DataType:     DataType {get{ return _type }}
	public var Value:        Any      {get{ return _value }}
	public var InitialValue: Any      {get{ return _initialValue }}
	public var IsConstant:   Bool     {get{ return _constant }}
	
	// MARK: Setters
	public func setName(name: String) throws {
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
	
	public func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	public func setType(type: DataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
	}

	public func setValue(val: Any) throws {
		if self._constant {
			throw Errors.isConstant("")
		}
		
		if !_type.matches(value: val) {
			throw Errors.dataTypeMismatch("")
		}
		
		_value = val
	}
	
	public func setInitialValue(val: Any) throws {
		if !_type.matches(value: val) {
			throw Errors.dataTypeMismatch("")
		}
		_initialValue = val
		_value = val
	}
	
	public func setConstant(const: Bool) {
		self._constant = const
	}
}
