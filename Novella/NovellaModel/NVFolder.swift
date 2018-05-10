//
//  NVFolder.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVFolder {
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
	public var Name:      String       {get{ return _name }}
	public var Synopsis:  String       {get{ return _synopsis }}
	public var Variables: [NVVariable] {get{ return _variables }}
	public var Folders:   [NVFolder]   {get{ return _folders }}
	public var Parent:    NVFolder?    {get{ return _parent }}
	
	// MARK: Setters
	public func setName(_ name: String) throws {
		// if not in a parent folder, name conflict doesn't matter
		if nil == _parent {
			_name = name
			return
		}
		
		// parent folder can't contain the requested name already
		if _parent!.containsFolderName(name) {
			throw NVError.nameAlreadyTaken("Tried to change Folder \(_name) to \(name), but its parent Folder (\(_parent!.Name) already contains that name.")
		}
		_name = name
	}
	
	public func setSynopsis(_ synopsis: String) {
		self._synopsis = synopsis
	}
	
	// MARK: Folders
	public func contains(folder: NVFolder) -> Bool {
		return _folders.contains(folder)
	}
	
	public func containsFolderName(_ name: String) -> Bool {
		return _folders.contains(where: {$0._name == name})
	}
	
	@discardableResult
	public func add(folder: NVFolder) throws -> NVFolder {
		// cannot add self
		if folder == self {
			throw NVError.invalid("Tried to add Folder to self (\(_name)).")
		}
		// already a child
		if contains(folder: folder) {
			throw NVError.invalid("Tried to add Folder but it already exists (\(folder._name) to \(_name)).")
		}
		// already contains same name
		if containsFolderName(folder._name) {
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
	
	public func remove(folder: NVFolder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw NVError.invalid("Tried to remove Folder (\(folder._name)) from (\(_name)) but it was not a child.")
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
	}
	
	public func hasDescendant(folder: NVFolder) -> Bool {
		// check this folder
		if self.contains(folder: folder) {
			return true
		}
		// check all children
		for child in _folders {
			if child.hasDescendant(folder: folder) {
				return true
			}
		}
		return false
	}
	
	// MARK: Variables
	public func contains(variable: NVVariable) -> Bool {
		return _variables.contains(variable)
	}
	
	public func containsVariableName(_ name: String) -> Bool {
		return _variables.contains(where: {$0._name == name})
	}
	
	@discardableResult
	public func add(variable: NVVariable) throws -> NVVariable {
		// already a child
		if contains(variable: variable) {
			throw NVError.invalid("Tried to add Variable but it already exists (\(variable._name) to \(_name)).")
		}
		// already contains same name
		if containsVariableName(variable._name) {
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
	
	public func remove(variable: NVVariable) throws {
		guard let idx = _variables.index(of: variable) else {
			throw NVError.invalid("Tried to remove Variable (\(variable._name)) from (\(_name)) but it was not a child.")
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
	}
	
	
	// MARK - Debug
	public func debugPrint(indent: Int) {
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

// MARK: NVIdentifiable
extension NVFolder: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: NVPathable
extension NVFolder: NVPathable {
	public func localPath() -> String {
		return _name
	}
	
	public func parentPath() -> NVPathable? {
		return _parent
	}
}

// MARK: Equatable
extension NVFolder: Equatable {
	public static func == (lhs: NVFolder, rhs: NVFolder) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
