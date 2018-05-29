//
//  NVTransfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVTransfer {
	internal var _destination: NVLinkable?
	fileprivate var _function: NVFunction
	
	init() {
		self._destination = nil
		self._function = NVFunction()
	}
	
	public var Destination: NVLinkable? {
		get{ return _destination }
	}
	public var Function: NVFunction {
		get{ return _function }
	}
}
