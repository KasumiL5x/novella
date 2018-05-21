//
//  UserDefaults+Color.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

extension UserDefaults {
	func set(_ value: NSColor, forKey key: String) {
		let colorData = NSKeyedArchiver.archivedData(withRootObject: value)
		set(colorData, forKey: key)
	}
	
	func color(forKey key: String) -> NSColor? {
		var color: NSColor?
		if let colorData = data(forKey: key) {
			color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor
		}
		return color
	}
}
