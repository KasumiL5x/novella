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
	var closeFunc: ((TabItem) -> ())?
	
	init(title: String, icon: NSImage?, altIcon: NSImage?, tabItem: NSTabViewItem, selectable: Bool = true) {
		self.title = title
		self.icon = icon
		self.altIcon = altIcon
		self.tabItem = tabItem
		self.selectable = selectable
		
		self.menu = NSMenu()
		self.menu!.addItem(withTitle: "Close", action: #selector(TabItem.onMenuClose), keyEquivalent: "").target = self
	}
	
	@objc private func onMenuClose() {
		self.closeFunc?(self)
	}
}
extension TabItem: Equatable {
	static func == (lhs: TabItem, rhs: TabItem) -> Bool {
		return lhs.title == rhs.title
	}
}
