//
//  OutlinerGraphViewController.swift
//  novella
//
//  Created by Daniel Green on 16/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class OutlinerGraphViewController: NSSplitViewController {
	// MARK: - Variables
	private var _outlinerVC: OutlinerViewController?
	private var _graphVC: GraphViewController?
	
	// MARK: - Properties
	var OutlinerVC: OutlinerViewController? {
		get { return _outlinerVC }
	}
	var GraphVC: GraphViewController? {
		get { return _graphVC }
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if splitViewItems.count >= 2 {
			_outlinerVC = splitViewItems[0].viewController as? OutlinerViewController
			_graphVC = splitViewItems[1].viewController as? GraphViewController
		}
	}
	
	func toggleLeft() {
		if splitViewItems.count < 1 {
			return
		}
		splitViewItems[0].animator().isCollapsed = !splitViewItems[0].animator().isCollapsed
	}
	
	func toggleRight() {
		if splitViewItems.count < 2 {
			return
		}
		splitViewItems[1].animator().isCollapsed = !splitViewItems[1].animator().isCollapsed
	}
	
}
