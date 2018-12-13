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
		
		if isSelected {
			NSColor(named: "NVTableRowSelected")!.setFill()
			dirtyRect.fill()
		}
	}
}
