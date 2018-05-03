//
//  Condition.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import JavaScriptCore

class Condition {
	var _story: Story
	var _javascript: String
	
	init(story: Story) {
		self._story = story
		_javascript = ""
	}
	
	func execute() -> Bool {
		
		// create function (TODO: What happens if I redefine this function more than once?)
		var boolFunc = "function executeCondition() {\n"
		boolFunc += _javascript
		boolFunc += "\n}"
		
		print(boolFunc)
		
		// evaluate the script so JS knows about it
		_story._jsContext.evaluateScript(boolFunc)
		
		// get a reference to the function
		guard let execFunc = _story._jsContext.objectForKeyedSubscript("executeCondition") else {
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
