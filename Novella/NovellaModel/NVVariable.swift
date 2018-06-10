//
//  NVVariable.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVVariable: NSObject, NSCoding {
	private let _manager: NVStoryManager
	private let _uuid: NSUUID
	private var _name: String
	private var _synopsis: String
	private var _type: NVDataType
	private var _value: Any
	private var _initialValue: Any
	private var _constant: Bool
	internal var _folder: NVFolder?
	
	init(manager: NVStoryManager, uuid: NSUUID, name: String, type: NVDataType) {
		self._manager = manager
		self._uuid = uuid
		self._name = name
		self._synopsis = ""
		self._type = type
		self._value = type.defaultValue
		self._initialValue = type.defaultValue
		self._constant = false
		self._folder = nil
		super.init()
	}
	
	// MARK: Coding
	public override func isEqual(_ object: Any?) -> Bool {
		return self._uuid == (object as? NVVariable)?.UUID
	}
	public required init?(coder aDecoder: NSCoder) {
		self._manager = aDecoder.decodeObject(forKey: "_manager") as! NVStoryManager
		self._uuid = aDecoder.decodeObject(forKey: "_uuid") as! NSUUID
		self._name = aDecoder.decodeObject(forKey: "_name") as! String
		self._synopsis = aDecoder.decodeObject(forKey: "_synopsis") as! String
		self._type = aDecoder.decodeObject(forKey: "_type") as! NVDataType
		self._value = aDecoder.decodeObject(forKey: "_value") as Any
		self._initialValue = aDecoder.decodeObject(forKey: "_initialValue") as Any
		self._constant = aDecoder.decodeObject(forKey: "_constant") as! Bool
		self._folder = aDecoder.decodeObject(forKey: "_folder") as? NVFolder
	}
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(_manager, forKey: "_manager")
		aCoder.encode(_uuid, forKey: "_uuid")
		aCoder.encode(_name, forKey: "_name")
		aCoder.encode(_synopsis, forKey: "_synopsis")
		aCoder.encode(_type, forKey: "_type")
		aCoder.encode(_value, forKey: "_value")
		aCoder.encode(_initialValue, forKey: "_initialValue")
		aCoder.encode(_constant, forKey: "_constant")
		aCoder.encode(_folder, forKey: "_folder")
	}
	
	public var Name: String {
		get{ return _name }
		set{
			_name = newValue
			_manager.Delegates.forEach{$0.onStoryVariableNameChanged(variable: self, name: _name)}
		}
	}
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
	
	// MARK: Setters
	public func setType(_ type: NVDataType) {
		_type = type
		_value = type.defaultValue
		_initialValue = type.defaultValue
		// TODO: Can I somehow convert existing data safely or revert to defaults otherwise?
		
		_manager.Delegates.forEach{$0.onStoryVariableTypeChanged(variable: self, type: _type)}
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
		_manager.Delegates.forEach{$0.onStoryVariableValueChanged(variable: self, value: _value)}
	}
	
	public func setInitialValue(_ val: Any) {
		if !_type.matches(value: val) {
			print("NVVariable::setInitial(): Variable datatype mismatch (\(_type.stringValue) vs \(_type.stringValue)).")
			return
		}
		_initialValue = val
		_value = val
		_manager.Delegates.forEach{$0.onStoryVariableInitialValueChanged(variable: self, value: _initialValue)}
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
