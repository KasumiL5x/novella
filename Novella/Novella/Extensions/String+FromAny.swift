//
//  String+FromAny.swift
//  Novella
//
//  Created by Daniel Green on 22/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

extension String {
	static func fromAny(_ value: Any?) -> String {
		if let nonNil = value, !(nonNil is NSNull) {
			return String(describing: nonNil)
		}
		return ""
	}
}
