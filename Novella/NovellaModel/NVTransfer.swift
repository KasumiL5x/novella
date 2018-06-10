//
//  NVTransfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVTransfer: NSObject, NSCoding {
	internal var _destination: NVLinkable?
	private var _function: NVFunction
	
	override init() {
		self._destination = nil
		self._function = NVFunction()
		super.init()
	}
	
	// MARK: Coding
	public required init?(coder aDecoder: NSCoder) {
		self._destination = aDecoder.decodeObject(forKey: "_destination") as? NVLinkable
		self._function = aDecoder.decodeObject(forKey: "_function") as! NVFunction
	}
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(_destination, forKey: "_destination")
		aCoder.encode(_function, forKey: "_function")
	}
	
	public var Destination: NVLinkable? {
		get{ return _destination }
	}
	public var Function: NVFunction {
		get{ return _function }
	}
}
