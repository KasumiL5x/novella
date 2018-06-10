//
//  NVContext.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVContext: NVNode {
	override init(manager: NVStoryManager, uuid: NSUUID) {
		super.init(manager: manager, uuid: uuid)
	}
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
