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
		// TODO: Execute some kind of user-provided code etc.
	}
}
