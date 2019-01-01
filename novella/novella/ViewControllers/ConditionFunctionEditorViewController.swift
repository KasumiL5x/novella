//
//  ConditionFunctionEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 31/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class ConditionFunctionEditorViewController: NSViewController {
	@IBOutlet weak var _outlineView: NSOutlineView!
	
	private var _document: Document? = nil
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	func setup(doc: Document) {
		_document = doc
		
		// todo: make some dummy ones here and test the loading etc.
		
		print("TODO: Implement.")
	}
}

extension ConditionFunctionEditorViewController: NSOutlineViewDelegate {
	// custom row class
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return CustomTableRowView(frame: NSRect.zero)
	}
	
	// color even/odd rows
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = (row % 2 == 0) ? NSColor(named: "NVTableRowEven")! : NSColor(named: "NVTableRowOdd")!
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		print("TODO: viewFor tableColumn")
		return view
	}
}

extension ConditionFunctionEditorViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		print("TODO: numberOfChildrenOfItem")
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		print("TODO: childOfItem")
		return ""
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
}
