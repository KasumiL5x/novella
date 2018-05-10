//
//  NVTransfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVTransfer {
	var _destination: NVLinkable?
	var _function: NVFunction
	
	init() {
		self._destination = nil
		self._function = NVFunction()
	}
	
	// MARK: Properties
	public var Destination: NVLinkable? {get{ return _destination } set{ _destination = newValue }}
}
