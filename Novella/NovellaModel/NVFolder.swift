//
//  NVFolder.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVFolder {
	private let _manager: NVStoryManager
	private let _uuid: NSUUID
	private var _name: String
	private var _synopsis: String
	private var _folders: [NVFolder]
	private var _variables: [NVVariable]
	internal var _parent: NVFolder?
	
	init(manager: NVStoryManager, uuid: NSUUID, name: String) {
		self._manager = manager
		self._uuid = uuid
		self._name = name
		self._synopsis = ""
		self._folders = []
		self._variables = []
		self._parent = nil
	}
	
	// MARK: Properties
	public var Name: String {
		get{ return _name }
		set{
			_name = newValue
			_manager.Delegates.forEach{$0.onStoryFolderNameChanged(folder: self, name: _name)}
		}
	}
	public var Synopsis: String {
		get{ return _synopsis }
		set{
			_synopsis = newValue
			_manager.Delegates.forEach{$0.onStoryFolderSynopsisChanged(folder: self, synopsis: _synopsis)}
		}
	}
	public var Folders: [NVFolder] {
		get{ return _folders }
	}
	public var Variables: [NVVariable] {
		get{ return _variables }
	}
	public var Parent: NVFolder? {
		get{ return _parent }
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
		// unparent first
		if folder._parent != nil {
			try! folder._parent!.remove(folder: folder)
		}
		// now add
		folder._parent = self
		_folders.append(folder)
		
		_manager.Delegates.forEach{$0.onStoryFolderAddFolder(parent: self, child: folder)}
		return folder
	}
	
	public func remove(folder: NVFolder) throws {
		guard let idx = _folders.index(of: folder) else {
			throw NVError.invalid("Tried to remove Folder (\(folder._name)) from (\(_name)) but it was not a child.")
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryFolderRemoveFolder(parent: self, child: folder)}
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
		return _variables.contains(where: {$0.Name == name})
	}
	
	@discardableResult
	public func add(variable: NVVariable) throws -> NVVariable {
		// already a child
		if contains(variable: variable) {
			throw NVError.invalid("Tried to add Variable but it already exists (\(variable.Name) to \(_name)).")
		}
		// unparent first
		if variable.Folder != nil {
			try! variable.Folder?.remove(variable: variable)
		}
		// now add
		variable._folder = self
		_variables.append(variable)
		
		_manager.Delegates.forEach{$0.onStoryFolderAddVariable(parent: self, child: variable)}
		return variable
	}
	
	public func remove(variable: NVVariable) throws {
		guard let idx = _variables.index(of: variable) else {
			throw NVError.invalid("Tried to remove Variable (\(variable.Name)) from (\(_name)) but it was not a child.")
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
		
		_manager.Delegates.forEach{$0.onStoryFolderRemoveVariable(parent: self, child: variable)}
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

// MARK: - NVIdentifiable -
extension NVFolder: NVIdentifiable {
	public var UUID: NSUUID {
		return _uuid
	}
}

// MARK: - NVPathable -
extension NVFolder: NVPathable {
	public func localPath() -> String {
		return _name
	}
	
	public func parentPath() -> NVPathable? {
		return _parent
	}
}

// MARK: - Equatable -
extension NVFolder: Equatable {
	public static func == (lhs: NVFolder, rhs: NVFolder) -> Bool {
		return lhs.UUID == rhs.UUID
	}
}
