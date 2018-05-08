//
//  Set.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVFolder {
	let _uuid: NSUUID
	var _name: String
	var _synopsis: String
	var _folders: [NVFolder]
	var _variables: [NVVariable]
	var _parent: NVFolder?
	
	init(uuid: NSUUID, name: String) {
		self._uuid = uuid
		self._name = name
		self._synopsis = ""
		self._folders = []
		self._variables = []
		self._parent = nil
	}
	
	// MARK: Getters
	var Name:      String     {get{ return _name }}
	var Synopsis:  String     {get{ return _synopsis }}
	var Variables: [NVVariable] {get{ return _variables }}
	var Folders:   [NVFolder]   {get{ return _folders }}
	
	// MARK: Setters
	func setName(name: String) throws {
		// if not in a parent folder, name conflict doesn't matter
		if nil == _parent {
			_name = name
			return
		}
		
		// parent folder can't contain the requested name already
		if _parent!.containsFolderName(name: name) {
			throw NVError.nameAlreadyTaken("Tried to change VariableSet \(_name) to \(name), but its parent folder (\(_parent!.Name) already contains that name.")
		}
		_name = name
	}
	
	func setSynopsis(synopsis: String) {
		self._synopsis = synopsis
	}
	
	// MARK: Folders
	func contains(folder: NVFolder) -> Bool {
		return _folders.contains(folder)
	}
	
	func containsFolderName(name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	@discardableResult
	func add(folder: NVFolder) throws -> NVFolder {
		// cannot add self
		if folder == self {
			throw NVError.invalid("Tried to add Folder to self (\(_name)).")
		}
		// already a child
		if contains(folder: folder) {
			throw NVError.invalid("Tried to add Folder but it already exists (\(folder._name) to \(_name)).")
		}
		// already contains same name
		if containsFolderName(name: folder._name) {
			throw NVError.nameTaken("Tried to add Folder but its name was already in use (\(folder._name) to \(_name)).")
		}
		// unparent first
		if folder._parent != nil {
			try! folder._parent!.remove(folder: folder)
		}
		// now add
		folder._parent = self
		_folders.append(folder)
		
		return folder
	}
	
	func remove(folder: NVFolder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw NVError.invalid("Tried to remove Folder (\(folder._name)) from (\(_name)) but it was not a child.")
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
	}
	
	func hasDescendantFolder(folder: NVFolder) -> Bool {
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
	
	// MARK: Variables
	func contains(variable: NVVariable) -> Bool {
		return _variables.contains(variable)
	}
	
	func containsVariableName(name: String) -> Bool {
		return _variables.contains(where: {$0._name == name})
	}
	
	@discardableResult
	func add(variable: NVVariable) throws -> NVVariable {
		// already a child
		if contains(variable: variable) {
			throw NVError.invalid("Tried to add Variable but it already exists (\(variable._name) to \(_name)).")
		}
		// already contains same name
		if containsVariableName(name: variable._name) {
			throw NVError.nameTaken("Tried to add Variable but its name was already in use (\(variable._name) to \(_name)).")
		}
		// unparent first
		if variable._folder != nil {
			try! variable._folder?.remove(variable: variable)
		}
		// now add
		variable._folder = self
		_variables.append(variable)
		
		return variable
	}
	
	func remove(variable: NVVariable) throws {
		guard let idx = _variables.index(of: variable) else {
			throw NVError.invalid("Tried to remove Variable (\(variable._name)) from (\(_name)) but it was not a child.")
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
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
extension NVFolder: Pathable {
	func localPath() -> String {
		return _name
	}
	
	func parentPath() -> Pathable? {
		return _parent
	}
}

// MARK: Identifiable
extension NVFolder: Identifiable {
	var UUID: NSUUID {
		return _uuid
	}
}

// MARK: Equatable
extension NVFolder: Equatable {
	static func == (lhs: NVFolder, rhs: NVFolder) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
