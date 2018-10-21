//
//  NVFunction.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVFunction {
	// MARK: - Variables
	private let _story: NVStory
	
	// MARK: - Properties
	var JavaScript: String = "" {
		didSet {
			NVLog.log("Function updated.", level: .info)
			_story.Delegates.forEach{$0.nvFunctionDidUpdate(function: self)}
		}
	}

	// MARK: - Initialization
	init(story: NVStory) {
		self._story = story
	}

	// MARK: - Evaulation
	func evaluate() {
		var funcCode = "function executeFunction() {\n"
		funcCode += JavaScript
		funcCode += "\n}"
		NVLog.log("Function JS:\n\(funcCode)", level: .debug)
		
		// eval script so the JVM knows about it
		_story.JVM.evaluateScript(funcCode)
		
		// get reference to the function
		guard let execFunc = _story.JVM.objectForKeyedSubscript("executeFunction") else {
			NVLog.log("Function could not find function. Skipping.", level: .warning)
			return
		}
		
		// call the function and get its return value
		guard let _ = execFunc.call(withArguments: []) else {
			NVLog.log("Function could not execute. Skipping.", level: .warning)
			return
		}
	}
}
