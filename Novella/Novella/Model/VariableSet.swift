//
//  Set.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class VariableSet {
	var _name: String
	var _synopsis: String
	var _sets: [VariableSet]
	var _variables: [Variable]
	var _parent: VariableSet?
	
	public init(name: String) {
		self._name = name
		self._synopsis = ""
		self._sets = []
		self._variables = []
		self._parent = nil
	}
	
	// MARK: Getters
	public var Name:     String {get{ return _name }}
	public var Synopsis: String {get{ return _synopsis }}
	
	// MARK: Setters
	public func setName(name: String) throws {
		// if not in a parent set, name conflict doesn't matter
		if nil == _parent {
			_name = name
			return
		}
		
		// parent set can't contain the requested name already
		if _parent!.containsSet(name: name) {
			throw Errors.nameAlreadyTaken("Tried to change VariableSet \(_name) to \(name), but its parent set (\(_parent!.Name) already contains that name.")
		}
		_name = name
	}
	
	public func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	// MARK: Sets
	public func containsSet(name: String) -> Bool {
		return _sets.contains(where: {$0._name == name})
	}
	
	public func addSet(set: VariableSet) throws {
		if containsSet(name: set._name) {
			throw Errors.nameAlreadyTaken("Tried to add set \(set._name) as a child of set \(_name), but its name was already taken.")
		}
		set._parent = self
		_sets.append(set)
	}
	
	public func removeSet(name: String) throws {
		guard let idx = _sets.index(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to remove set \(name) from parent set \(_name), but its name was not found.")
		}
		_sets[idx]._parent = nil
		_sets.remove(at: idx)
	}
	
	public func getSet(name: String) throws -> VariableSet {
		guard let existing = _sets.first(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to get set \(name) from parent set \(_name), but its name was not found.")
		}
		return existing
	}
	
	// MARK: Variables
	public func containsVariable(name: String) -> Bool {
		return _variables.contains(where: {$0._name == name})
	}
	
	public func addVariable(variable: Variable) throws {
		if containsVariable(name: variable._name) {
			throw Errors.nameAlreadyTaken("Tried to add variable \(variable._name) as a child of set \(_name), but its name was already taken.")
		}
		variable._set = self
		_variables.append(variable)
	}
	
	public func removeVariable(name: String) throws {
		guard let idx = _variables.index(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to remove variable \(name) from parent set \(_name), but its name was not found.")
		}
		_variables[idx]._set = nil
		_variables.remove(at: idx)
	}
	
	public func getVariable(name: String) throws -> Variable {
		guard let existing = _variables.first(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to get variable \(name) from parent set \(_name), but its name was not found.")
		}
		return existing
	}
	
	
	// MARK - Debug
	public func debugPrint(indent: Int) {
		var str = ""
		
		// current set w/ indent
		str = "|"
		for _ in 0...(indent <= 0 ? 0 : indent-1) {
			str += "-"
		}
		str += "\(self._name)(S)\n"
		print(str, terminator: "")
		
		// all variables
		for v in _variables {
			str = "|"
			for _ in 0...(indent+1) {
				str += "-"
			}
			str += "\\\(v.Name)(V)\n"
			print(str, terminator: "")
		}
		
		// repeat for child sets
		for c in _sets {
			c.debugPrint(indent: indent+2)
		}
	}
}
