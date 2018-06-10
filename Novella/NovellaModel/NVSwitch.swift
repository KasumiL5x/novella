//
//  NVSwitch.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVSwitch : NVBaseLink {
	private var _variable: NVVariable?
	private var _defaultTransfer: NVTransfer
	private var _values: [AnyHashable:NVTransfer]
	
	override init(manager: NVStoryManager, uuid: NSUUID, origin: NVLinkable) {
		self._variable = nil
		self._defaultTransfer = NVTransfer()
		self._values = [:]
		
		super.init(manager: manager, uuid: uuid, origin: origin)
	}
	
	// MARK: Coding
	required public init?(coder aDecoder: NSCoder) {
		self._variable = aDecoder.decodeObject(forKey: "_variable") as? NVVariable
		self._defaultTransfer = aDecoder.decodeObject(forKey: "_defaultTransfer") as! NVTransfer
		self._values = aDecoder.decodeObject(forKey: "_values") as! [AnyHashable:NVTransfer]
		super.init(coder: aDecoder)
	}
	public override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(_variable, forKey: "_variable")
		aCoder.encode(_defaultTransfer, forKey: "_defaultTransfer")
		aCoder.encode(_values, forKey: "_values")
	}
}
