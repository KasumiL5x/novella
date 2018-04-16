//
//  Identifiable.swift
//  Novella
//
//  Created by Daniel Green on 16/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class Identifiable {
	let _uniqueID: String
	
	init() {
		_uniqueID = NSUUID().uuidString
	}
}
