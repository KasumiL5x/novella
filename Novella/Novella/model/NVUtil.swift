//
//  NVUtil.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVUtil {
	static func randomString(length: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0...length-1).map{_ in letters.randomElement()!})
	}
}
