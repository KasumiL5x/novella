//
//  NVFunction.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVFunction {
	// MARK: - - Variables -
	var _javascript: String
	
	// MARK: - - Initialization -
	init() {
		self._javascript = ""
	}
	
	// MARK: - - Properties -
	public var Javascript: String {
		get{ return _javascript }
		set{ _javascript = newValue } // TODO: Make this a function and validate the JS upon change?
	}
	
	// MARK: - - Functions -
	func execute() {
		// TODO: Execute some kind of user-provided code etc.
	}
}
