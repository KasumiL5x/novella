//
//  NVFunction.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVFunction {
	private var _javascript: String
	
	init() {
		self._javascript = ""
	}
	
	public var Javascript: String {
		get{ return _javascript }
		set{ _javascript = newValue } // TODO: Make this a function and validate the JS upon change?
	}
	
	func execute() {
		// TODO: Execute some kind of user-provided code etc.
	}
}
