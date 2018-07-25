//
//  NVFunction.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVFunction {
	// MARK: - Variables -
	private let _manager: NVStoryManager
	private var _javascript: String
	
	// MARK: - Properties -
	public var Javascript: String {
		get{ return _javascript }
		set{
			_javascript = newValue
			_manager.Delegates.forEach{$0.onStoryFunctionUpdated(function: self)}
		} // TODO: Make this a function and validate the JS upon change?
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager) {
		self._manager = manager
		self._javascript = ""
	}
	
	// MARK: - Functions -
	func execute() {
		var funcCode = "function executeFunction() {\n"
		funcCode += _javascript
		funcCode += "\n}"
		
		NVLog.log("Function JS:\n\(funcCode)", level: .debug)
		
		// evaluate the script so JS knows about it
		_manager._jsContext.evaluateScript(funcCode)
		
		// get a reference to the function
		guard let execFunc = _manager._jsContext.objectForKeyedSubscript("executeFunction") else {
			fatalError("Could not find JavaScript function executeFunction().")
		}
		
		// call the function so we can get its value back
		guard let _ = execFunc.call(withArguments: []) else {
			fatalError("Could not execute JavaScript function executeFunction().")
		}
	}
}
