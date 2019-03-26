//
//  NSColor+Hex.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

public extension NSColor {
	static func fromHex(_ hex:String) -> NSColor {
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
	
	func toHex() -> String {
		let red = Int(round(self.redComponent * 0xFF))
		let green = Int(round(self.greenComponent * 0xFF))
		let blue = Int(round(self.blueComponent * 0xFF))
		let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
		return hexString as String
	}
}

public extension NSColor {
	func lighter(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat?=nil) -> NSColor {
		return NSColor(calibratedHue: hueComponent,
									 saturation: max(saturationComponent - val, 0.0),
									 brightness: brightnessComponent,
									 alpha: alpha ?? alphaComponent)
	}
	func darker(removeValue val: CGFloat, resultAlpha alpha: CGFloat?=nil) -> NSColor {
		return NSColor(calibratedHue: hueComponent,
									 saturation: saturationComponent,
									 brightness: max(brightnessComponent - val, 0.0),
									 alpha: alpha ?? alphaComponent)
	}
}

public extension NSColor {
	func inverted() -> NSColor {
		return NSColor(calibratedRed: 1.0 - self.redComponent, green: 1.0 - self.greenComponent, blue: 1.0 - self.blueComponent, alpha: self.alphaComponent)
	}
}
