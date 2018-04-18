//
//  Engine.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Engine {
	let _story: Story
	
	// All objects that are Identifiable. Can be searched.
	var _identifiables: [Identifiable]
	
	init() {
		self._story = Story()
		self._identifiables = []
	}
	
	// MARK: Getters
	var TheStory: Story {get{ return _story }}
	
	// MARK: Identifiables
	func find(uuid: String) throws -> Identifiable {
		let uuidObj = NSUUID(uuidString: uuid)
		guard let element = _identifiables.first(where: {$0.UUID == uuidObj}) else {
			throw Errors.invalid("Tried to find by UUID but no match was found (\(uuid)).")
		}
		return element
	}
	
	// MARK: Folders
	func makeFolder(name: String) -> Folder {
		let folder = Folder(name: name)
		_identifiables.append(folder)
		return folder
	}
	
	// MARK: Variables
	func makeVariable(name: String, type: DataType) -> Variable {
		let variable = Variable(name: name, type: type)
		_identifiables.append(variable)
		return variable
	}
}
