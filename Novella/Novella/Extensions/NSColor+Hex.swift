//
//  CGColor+Hex.swift
//  Novella
//
//  Created by Daniel Green on 05/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

public extension NSColor {
	public static func fromHex(_ hex:String) -> NSColor {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return NSColor.gray
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return NSColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	public func toHex() -> String {
		let red = Int(round(self.redComponent * 0xFF))
		let green = Int(round(self.greenComponent * 0xFF))
		let blue = Int(round(self.blueComponent * 0xFF))
		let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
		return hexString as String
	}
}
