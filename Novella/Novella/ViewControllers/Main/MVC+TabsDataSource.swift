//
//  MVC+TabsDataSource.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import protocol KPCTabsControl.TabsControlDataSource
import class KPCTabsControl.TabsControl

class TabsDataSource: NSObject, TabsControlDataSource {
	fileprivate var _tabs: [TabItem]
	
	override init() {
		_tabs = []
	}
	
	var Tabs: [TabItem] {
		get{ return _tabs }
		set{ _tabs = newValue }
	}
	
	func tabsControlNumberOfTabs(_ control: TabsControl) -> Int {
		return _tabs.count
	}
	
	func tabsControl(_ control: TabsControl, itemAtIndex index: Int) -> AnyObject {
		return _tabs[index]
	}
	
	func tabsControl(_ control: TabsControl, titleForItem item: AnyObject) -> String {
		return (item as! TabItem).title
	}
	
	func tabsControl(_ control: TabsControl, menuForItem item: AnyObject) -> NSMenu? {
		return (item as! TabItem).menu
	}
	
	func tabsControl(_ control: TabsControl, iconForItem item: AnyObject) -> NSImage? {
		return (item as! TabItem).icon
	}
	
	func tabsControl(_ control: TabsControl, titleAlternativeIconForItem item: AnyObject) -> NSImage? {
		return (item as! TabItem).altIcon
	}
}
