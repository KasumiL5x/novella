//
//  Set.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Folder {
	let _uuid: NSUUID
	var _name: String
	var _synopsis: String
	var _folders: [Folder]
	var _variables: [Variable]
	var _parent: Folder?
	
	init(name: String) {
		self._uuid = NSUUID()
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
		if _parent!.containsFolderName(name: name) {
			throw Errors.nameAlreadyTaken("Tried to change VariableSet \(_name) to \(name), but its parent folder (\(_parent!.Name) already contains that name.")
		}
		_name = name
	}
	
	func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	// MARK: Folders
	func contains(folder: Folder) -> Bool {
		return _folders.contains(folder)
	}
	
	func containsFolderName(name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	func add(folder: Folder) throws {
		// cannot add self
		if folder == self {
			throw Errors.invalid("Tried to add Folder to self (\(_name)).")
		}
		// already a child
		if contains(folder: folder) {
			throw Errors.invalid("Tried to add Folder but it already exists (\(folder._name) to \(_name)).")
		}
		// already contains same name
		if containsFolderName(name: folder._name) {
			throw Errors.nameTaken("Tried to add Folder but its name was already in use (\(folder._name) to \(_name)).")
		}
		// unparent first
		if folder._parent != nil {
			try! folder._parent!.remove(folder: folder)
		}
		// now add
		folder._parent = self
		_folders.append(folder)
	}
	
	func remove(folder: Folder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw Errors.invalid("Tried to remove Folder (\(folder._name)) from (\(_name)) but it was not a child.")
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
	}
	
	func hasDescendantFolder(folder: Folder) -> Bool {
		// check this folder
		if self.contains(folder: folder) {
			return true
		}
		// check all children
		for child in _folders {
			if child.hasDescendantFolder(folder: folder) {
				return true
			}
		}
		return false
	}
	
	// MARK: Folder Convenience Functions
	func mkdir(name: String) throws -> Folder {
		let newFolder = Folder(name: name)
		try add(folder: newFolder)
		return newFolder
	}
	
	// MARK: Variables
	func contains(variable: Variable) -> Bool {
		return _variables.contains(variable)
	}
	
	func containsVariableName(name: String) -> Bool {
		return _variables.contains(where: {$0._name == name})
	}
	
	func add(variable: Variable) throws {
		// already a child
		if contains(variable: variable) {
			throw Errors.invalid("Tried to add Variable but it already exists (\(variable._name) to \(_name)).")
		}
		// already contains same name
		if containsVariableName(name: variable._name) {
			throw Errors.nameTaken("Tried to add Variable but its name was already in use (\(variable._name) to \(_name)).")
		}
		// unparent first
		if variable._folder != nil {
			try! variable._folder?.remove(variable: variable)
		}
		// now add
		variable._folder = self
		_variables.append(variable)
	}
	
	func remove(variable: Variable) throws {
		guard let idx = _variables.index(of: variable) else {
			throw Errors.invalid("Tried to remove Variable (\(variable._name)) from (\(_name)) but it was not a child.")
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
	}
	
	// MARK: Variable Convenience Functions
	func mkvar(name: String, type: DataType) throws -> Variable {
		let newVar = Variable(name: name, type: type)
		try add(variable: newVar)
		return newVar
	}
	
	
	// MARK - Debug
	func debugPrint(indent: Int) {
		var str = ""
		
		// current folder w/ indent
		str = "|"
		for _ in 0...(indent <= 0 ? 0 : indent-1) {
			str += "-"
		}
		str += "[\(self._name)](\(self._folders.count) subfolders; \(self._variables.count) variables)\n"
		print(str, terminator: "")
		
		// all variables
		for v in _variables {
			str = "|"
			for _ in 0...(indent+1) {
				str += "-"
			}
			str += "\(v.Name)(\(v.DataType))\n"
			print(str, terminator: "")
		}
		
		// repeat for child folder
		for c in _folders {
			c.debugPrint(indent: indent+2)
		}
	}
}

// MARK: Pathable
extension Folder: Pathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> Pathable? {
		return _parent
	}
}

// MARK: Identifiable
extension Folder: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension Folder: Equatable {
	static func == (lhs: Folder, rhs: Folder) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
