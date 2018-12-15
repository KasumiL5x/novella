//
//  NVCondition.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVCondition {
	private let _story: NVStory
	var Code: String = "return true;" {
		didSet {
			if Code.isEmpty {
				Code = "return true;"
			}
			_story.Delegates.allObjects.forEach{($0 as! NVStoryDelegate).nvConditionCodeDidChange(story: _story, condition: self)}
		}
	}
	private(set) var FunctionName: String
	
	init(story: NVStory) {
		self._story = story
		self.FunctionName = "nvCondition" + NVUtil.randomString(length: 10)
	}
	
	func evaluate() -> Bool {
		var condCode = "function " + FunctionName + "{\n"
		condCode += Code
		condCode += "\n}"
		NVLog.log("Running Condition Code:\n\(condCode)", level: .debug)
		
		// eval so JS knows about it
		_story.JVM.evaluateScript(condCode)
		
		// get a reference to the function
		guard let funcRef = _story.JVM.objectForKeyedSubscript(FunctionName) else {
			NVLog.log("Tried to run Condition but couldn't find function name (\(FunctionName)).", level: .warning)
			return false
		}
		
		//  actually run the function
		guard let result = funcRef.call(withArguments: []) else {
			NVLog.log("Tried to run Condition but it failed (\(FunctionName)).", level: .warning)
			return false
		}
		
		return result.toBool()
	}
}
