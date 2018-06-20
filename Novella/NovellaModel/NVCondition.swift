//
//  NVCondition.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

public class NVCondition {
	// MARK: - Variables -
	private let _manager: NVStoryManager
	private var _javascript: String
	
	// MARK: - Properties -
	public var Javascript: String {
		get{ return _javascript }
		set{
			_javascript = newValue
			_manager.Delegates.forEach{$0.onStoryConditionUpdated(condition: self)}
		} // TODO: Make this a function and validate the JS upon change?
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager) {
		self._manager = manager
		_javascript = ""
	}
	
	// MARK: - Functions -
	func execute() -> Bool {
		// create function (TODO: What happens if I redefine this function more than once?)
		var boolFunc = "function executeCondition() {\n"
		boolFunc += _javascript.isEmpty ? "return true;" : _javascript
		boolFunc += "\n}"
		
		print(boolFunc)
		
		// evaluate the script so JS knows about it
		_manager._jsContext.evaluateScript(boolFunc)
		
		// get a reference to the function
		guard let execFunc = _manager._jsContext.objectForKeyedSubscript("executeCondition") else {
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
