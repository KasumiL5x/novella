//
//  NVFolder.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVFolder: NVIdentifiable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	private var _parent: NVFolder?
	
	// MARK: - Properties
	var Name: String = "" {
		didSet {
			NVLog.log("Folder (\(ID)) renamed (\(oldValue)->\(Name)).", level: .info)
			_story.Delegates.forEach{$0.nvFolderDidRename(folder: self)}
		}
	}
	var Synopsis: String = "" {
		didSet {
			NVLog.log("Folder (\(ID)) synopsis set to \"\(Synopsis)\".", level: .info)
			_story.Delegates.forEach{$0.nvFolderSynopsisDidChange(folder: self)}
		}
	}
	private(set) var Folders: [NVFolder] = []
	private(set) var Variables: [NVVariable] = []
	
	
	// MARK: - Initialization
	init(id: NSUUID, story: NVStory, name: String) {
		self.ID = id
		self._story = story
		self._parent = nil
		self.Name = name
	}
	
	// MARK: - Other
	func removeFromParent() {
		_parent?.remove(folder: self) // creates 'floating' folder - use with care
	}
	
	// MARK: - Folders
	func contains(folder: NVFolder) -> Bool {
		return Folders.contains(folder)
	}
	@discardableResult func add(folder: NVFolder) -> NVFolder {
		if folder == self {
			NVLog.log("Tried to add Folder to itself (\(ID))", level: .warning)
			return self
		}
		
		if contains(folder: folder) {
			NVLog.log("Tried to add Folder (\(folder.ID)) to Folder (\(ID)) but it was already added.", level: .warning)
			return folder
		}
		
		if let oldParent = folder._parent {
			oldParent.remove(folder: folder)
		}
		folder._parent = self
		Folders.append(folder)
		
		NVLog.log("Folder (\(folder.ID)) added to Folder (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvFolderDidAddFolder(parent: self, child: folder)}
		return folder
	}
	func remove(folder: NVFolder) {
		guard let idx = Folders.index(of: folder) else {
			NVLog.log("Tried to remove Folder (\(folder.ID)) from Folder (\(ID)) but it wasn't contained.", level: .warning)
			return
		}
		Folders[idx]._parent = nil
		Folders.remove(at: idx)
		
		NVLog.log("Folder (\(folder.ID)) removed from Folder (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvFolderDidRemoveFolder(parent: self, child: folder)}
	}
	
	// MARK: - Variables
	func contains(variable: NVVariable) -> Bool {
		return Variables.contains(variable)
	}
	@discardableResult func add(variable: NVVariable) -> NVVariable {
		if contains(variable: variable) {
			NVLog.log("Tried to add Variable (\(variable.ID)) to Folder (\(ID)) but it was already added.", level: .warning)
			return variable
		}
		
		if let oldParent = variable._parent {
			oldParent.remove(variable: variable)
		}
		variable._parent = self
		Variables.append(variable)
		
		NVLog.log("Variable (\(variable.ID)) added to Folder (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvFolderDidAddVariable(parent: self, child: variable)}
		return variable
	}
	func remove(variable: NVVariable) {
		guard let idx = Variables.index(of: variable) else {
			NVLog.log("Tried to remove Variable (\(variable.ID)) from Folder (\(ID)) but it wasn't contained.", level: .warning)
			return
		}
		Variables[idx]._parent = nil
		Variables.remove(at: idx)
		
		NVLog.log("Variable (\(variable.ID)) removed from Folder (\(ID)).", level: .info)
		_story.Delegates.forEach{$0.nvFolderDidRemoveVariable(parent: self, child: variable)}
	}
}

extension NVFolder: NVPathable {
	func localPath() -> String {
		return Name
	}
	
	func parentPathable() -> NVPathable? {
		return _parent
	}
}

extension NVFolder: Equatable {
	static func ==(lhs: NVFolder, rhs: NVFolder) -> Bool {
		return lhs.ID == rhs.ID
	}
}
