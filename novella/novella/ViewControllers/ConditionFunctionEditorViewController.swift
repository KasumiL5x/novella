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
	private var _functionHeader: String = "Functions"
	private var _conditionHeader: String = "Conditions"
	
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
		
		let _ = doc.Story.makeFunction()
		let _ = doc.Story.makeFunction()
		let _ = doc.Story.makeCondition()
		let _ = doc.Story.makeCondition()
		
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
		
		// handle groups
		if let asString = item as? String {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("GroupCell"), owner: self)
			(view as? NSTableCellView)?.textField?.stringValue = asString
			return view
		}
		
		// handle others
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainCell"), owner: self)
		switch item {
		case let asFunction as NVFunction:
			(view as? NSTableCellView)?.textField?.stringValue = asFunction.FunctionName
			
		case let asCondition as NVCondition:
			(view as? NSTableCellView)?.textField?.stringValue = asCondition.FunctionName
			
		default:
			(view as? NSTableCellView)?.textField?.stringValue = "ERROR"
		}
		
		return view
	}
}

extension ConditionFunctionEditorViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return 2 // function and condition headers
		}
		if let asString = item as? String {
			if asString == _functionHeader {
				return _document?.Story.Functions.count ?? 0
			}
			if asString == _conditionHeader {
				return _document?.Story.Conditions.count ?? 0
			}
		}
//		if item == nil {
//			guard let doc = _document else {
//				return 0
//			}
//			return doc.Story.Functions.count + doc.Story.Conditions.count
//		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard let doc = _document else {
			fatalError()
		}
		
		if item == nil {
			if index == 0 {
				return _functionHeader
			}
			if index == 1 {
				return _conditionHeader
			}
		}
		
		if let asString = item as? String {
			if asString == _functionHeader {
				return doc.Story.Functions[index]
			}
			if asString == _conditionHeader {
				return doc.Story.Conditions[index]
			}
		}
		
//		if index < doc.Story.Functions.count {
//			return doc.Story.Functions[index]
//		}
//
//		let offset = doc.Story.Functions.count
//		if index < (doc.Story.Conditions.count + offset) {
//			return doc.Story.Conditions[index - offset]
//		}
		
		fatalError()
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is String
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is String
	}
}
