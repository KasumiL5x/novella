//
//  NVListener.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVListener: NVNode {
	private let _condition: NVCondition
	private let _transfer: NVTransfer
	
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._condition = NVCondition(manager: manager)
		self._transfer = NVTransfer()
		
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: Coding
	public required init?(coder aDecoder: NSCoder) {
		self._condition = aDecoder.decodeObject(forKey: "_condition") as! NVCondition
		self._transfer = aDecoder.decodeObject(forKey: "_transfer") as! NVTransfer
		super.init(coder: aDecoder)
	}
	public override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(_condition, forKey: "_condition")
		aCoder.encode(_transfer, forKey: "_transfer")
	}
}
