//
//  NVTransfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVTransfer {
	// MARK: - Variables -
	internal var _destination: NVObject?
	private var _function: NVFunction
	
	// MARK: - Properties -
	public var Destination: NVObject? {
		get{ return _destination }
	}
	public var Function: NVFunction {
		get{ return _function }
	}
	
	// MARK: - Initialization -
	init() {
		self._destination = nil
		self._function = NVFunction()
	}
}
