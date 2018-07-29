//
//  NVFolder.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVFolder: NVObject {
	// MARK: - Variables -
	private var _synopsis: String
	private var _folders: [NVFolder]
	private var _variables: [NVVariable]
	internal var _parent: NVFolder?
	
	// MARK: - Properties -
	public var Synopsis: String {
		get{ return _synopsis }
		set{
			_synopsis = newValue
			
			NVLog.log("Folder (\(self.UUID)) synopsis set to (\(_synopsis)).", level: .info)
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
	
	// MARK: - Initialization -
	init(manager: NVStoryManager, uuid: NSUUID, name: String) {
		self._synopsis = ""
		self._folders = []
		self._variables = []
		self._parent = nil
		super.init(manager: manager, uuid: uuid)
		self.Name = name
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return false
	}
	
	// MARK: Folders
	public func contains(folder: NVFolder) -> Bool {
		return _folders.contains(folder)
	}
	
	public func containsFolderName(_ name: String) -> Bool {
		return _folders.contains(where: {$0.Name == name})
	}
	
	@discardableResult
	public func add(folder: NVFolder) -> NVFolder {
		// cannot add self
		if folder == self {
			NVLog.log("Tried to add a Folder to itself (\(folder.UUID.uuidString)).", level: .warning)
			return self
		}
		// already a child
		if contains(folder: folder) {
			NVLog.log("Tried to add a Folder (\(folder.UUID.uuidString)) to Folder (\(self.UUID.uuidString)) but it is already a child.", level: .warning)
			return folder
		}
		// unparent first
		if folder._parent != nil {
			folder._parent!.remove(folder: folder)
		}
		// now add
		folder._parent = self
		_folders.append(folder)
		
		NVLog.log("Folder (\(folder.UUID)) added to Folder (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryFolderAddFolder(parent: self, child: folder)}
		return folder
	}
	
	public func remove(folder: NVFolder) {
		guard let idx = _folders.index(of: folder) else {
			NVLog.log("Tried to remove a Folder (\(folder.UUID.uuidString)) from Folder (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_folders[idx]._parent = nil
		_folders.remove(at: idx)
		
		NVLog.log("Folder (\(folder.UUID)) removed from (\(self.UUID)).", level: .info)
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
	public func add(variable: NVVariable) -> NVVariable {
		// already a child
		if contains(variable: variable) {
			NVLog.log("Tried to add a Variable (\(variable.UUID.uuidString)) to Folder (\(self.UUID.uuidString)) but it already exists.", level: .warning)
			return variable
		}
		// unparent first
		if variable.Folder != nil {
			variable.Folder?.remove(variable: variable)
		}
		// now add
		variable._folder = self
		_variables.append(variable)
		
		NVLog.log("Variable (\(variable.UUID)) added to Folder (\(self.UUID)).", level: .info)
		_manager.Delegates.forEach{$0.onStoryFolderAddVariable(parent: self, child: variable)}
		return variable
	}
	
	public func remove(variable: NVVariable) {
		guard let idx = _variables.index(of: variable) else {
			NVLog.log("Tried to remove a Variable (\(variable.UUID.uuidString)) from Folder (\(self.UUID.uuidString)) but it was not a child.", level: .warning)
			return
		}
		_variables[idx]._folder = nil
		_variables.remove(at: idx)
		
		NVLog.log("Variable (\(variable.UUID)) removed from Folder (\(self.UUID)).", level: .info)
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
		str += "[\(self.Name)](\(self._folders.count) subfolders; \(self._variables.count) variables)\n"
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

// MARK: - NVPathable -
extension NVFolder: NVPathable {
	public func localPath() -> String {
		return Name
	}
	
	public func parentPath() -> NVPathable? {
		return _parent
	}
}
