//
//  NVCondition.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

public class NVCondition {
	// MARK: - - Variables -
	var _storyManager: NVStoryManager
	var _javascript: String
	
	// MARK: - - Initialization -
	init(storyManager: NVStoryManager) {
		self._storyManager = storyManager
		_javascript = ""
	}
	
	// MARK: - - Properties -
	public var Javascript: String {
		get{ return _javascript }
		set{ _javascript = newValue } // TODO: Make this a function and validate the JS upon change?
	}
	
	// MARK: - - Functions -
	func execute() -> Bool {
		// create function (TODO: What happens if I redefine this function more than once?)
		var boolFunc = "function executeCondition() {\n"
		boolFunc += _javascript
		boolFunc += "\n}"
		
		print(boolFunc)
		
		// evaluate the script so JS knows about it
		_storyManager._jsContext.evaluateScript(boolFunc)
		
		// get a reference to the function
		guard let execFunc = _storyManager._jsContext.objectForKeyedSubscript("executeCondition") else {
			fatalError("Could not find JavaScript function executeCondition().")
		}
		
		// call the function so we can get its value back
		guard let result = execFunc.call(withArguments: []) else {
			fatalError("Could not execute JavaScript function executeCondition().")
		}
		
		// JS will always return somethign, so worst case we get false
		return result.toBool()
	}
}
