//
//  Set.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class Folder {
	var _name: String
	var _synopsis: String
	var _folders: [Folder]
	var _variables: [Variable]
	var _parent: Folder?
	
	init(name: String) {
		self._name = name
		self._synopsis = ""
		self._folders = []
		self._variables = []
		self._parent = nil
	}
	
	// MARK: Getters
	var Name:     String {get{ return _name }}
	var Synopsis: String {get{ return _synopsis }}
	
	// MARK: Setters
	func setName(name: String) throws {
		// if not in a parent folder, name conflict doesn't matter
		if nil == _parent {
			_name = name
			return
		}
		
		// parent folder can't contain the requested name already
		if _parent!.containsFolder(name: name) {
			throw Errors.nameAlreadyTaken("Tried to change VariableSet \(_name) to \(name), but its parent folder (\(_parent!.Name) already contains that name.")
		}
		_name = name
	}
	
	func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	// MARK: Folders
	func containsFolder(name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	func addFolder(folder: Folder) throws {
		if containsFolder(name: folder._name) {
			throw Errors.nameAlreadyTaken("Tried to add folder \(folder._name) as a child of folder \(_name), but its name was already taken.")
		}
		folder._parent = self
		_folders.append(folder)
	}
	
	func removeFolder(name: String) throws {
		guard let idx = _folders.index(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to remove folder \(name) from parent folder \(_name), but its name was not found.")
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
	}
	
	func getFolder(name: String) throws -> Folder {
		guard let existing = _folders.first(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to get folder \(name) from parent folder \(_name), but its name was not found.")
		}
		return existing
	}
	
	// MARK: Variables
	func containsVariable(name: String) -> Bool {
		return _variables.contains(where: {$0._name == name})
	}
	
	func addVariable(variable: Variable) throws {
		if containsVariable(name: variable._name) {
			throw Errors.nameAlreadyTaken("Tried to add variable \(variable._name) as a child of folder \(_name), but its name was already taken.")
		}
		variable._folder = self
		_variables.append(variable)
	}
	
	func removeVariable(name: String) throws {
		guard let idx = _variables.index(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to remove variable \(name) from parent folder \(_name), but its name was not found.")
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
	}
	
	func getVariable(name: String) throws -> Variable {
		guard let existing = _variables.first(where: {$0._name == name}) else {
			throw Errors.nameNotFound("Tried to get variable \(name) from parent folder \(_name), but its name was not found.")
		}
		return existing
	}
	
	
	// MARK - Debug
	func debugPrint(indent: Int) {
		var str = ""
		
		// current folder w/ indent
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
		
		// repeat for child folder
		for c in _folders {
			c.debugPrint(indent: indent+2)
		}
	}
}
