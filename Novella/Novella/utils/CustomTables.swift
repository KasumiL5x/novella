//
//  CustomTables.swift
//  novella
//
//  Created by Daniel Green on 13/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CustomTableRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if isGroupRowStyle {
			isSelected ? NSColor.fromHex("#739cde").setFill() : NSColor.fromHex("#f7f7f7").setFill()
			dirtyRect.fill()
		} else {
			if isSelected {
				NSColor.fromHex("#739cde").setFill()
				dirtyRect.fill()
			}
		}		
	}
}

class CustomTableColors {
	static let RowEven = NSColor.fromHex("#FEFEFE")
	static let RowOdd = NSColor.fromHex("#F9F9F9")
}

