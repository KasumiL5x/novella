//
//  NVCondition.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVCondition {
	// MARK: - Variables
	private let _story: NVStory
	
	// MARK: - Properties
	var JavaScript: String = "return true;" {
		didSet {
			NVLog.log("Condition updated.", level: .info)
			_story.Delegates.forEach{$0.nvConditionDidUpdate(condition: self)}
		}
	}
	
	// MARK: - Initialization
	init(story: NVStory) {
		self._story = story
	}
	
	// MARK: - Evaulation
	func evaluate() -> Bool {
		var boolFunc = "function executeCondition() {\n"
		boolFunc += JavaScript.isEmpty ? "return true;" : JavaScript
		boolFunc += "\n}"
		NVLog.log("Condition JS:\n\(boolFunc)", level: .debug)
		
		// eval script so the JVM knows about it
		_story.JVM.evaluateScript(boolFunc)
		
		// get reference to the function
		guard let execFunc = _story.JVM.objectForKeyedSubscript("executeCondition") else {
			NVLog.log("Condition could not find function. Returning false.", level: .warning)
			return false
		}
		
		// call the function and get its return value
		guard let result = execFunc.call(withArguments: []) else {
			NVLog.log("Condition could not execute. Returning false.", level: .warning)
			return false
		}
		
		// JS always returns something, so worst case we get false
		return result.toBool()
	}
}
