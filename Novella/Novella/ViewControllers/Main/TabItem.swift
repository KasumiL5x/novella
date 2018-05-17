//
//  TabItem.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class TabItem {
	var title: String = ""
	var icon: NSImage?
	var menu: NSMenu?
	var altIcon: NSImage?
	var selectable: Bool
	var tabItem: NSTabViewItem
	
	init(title: String, icon: NSImage?, menu: NSMenu?, altIcon: NSImage?, tabItem: NSTabViewItem, selectable: Bool = true) {
		self.title = title
		self.icon = icon
		self.menu = menu
		self.altIcon = altIcon
		self.tabItem = tabItem
		self.selectable = selectable
	}
}
extension TabItem: Equatable {
	static func == (lhs: TabItem, rhs: TabItem) -> Bool {
		return lhs.title == rhs.title
	}
}
