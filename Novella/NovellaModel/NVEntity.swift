//
//  NVEntity.swift
//  NovellaModel
//
//  Created by Daniel Green on 25/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVEntity: NVObject {
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	public override func isLinkable() -> Bool {
		return false
	}
}
