//
//  ConditionFunctionEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 31/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CFEHeader: Equatable {
	static func == (lhs: CFEHeader, rhs: CFEHeader) -> Bool {
		return lhs.name == rhs.name
	}
	
	public var name: String = ""
	init(name: String) {
		self.name = name
	}
}

class ConditionFunctionEditorViewController: NSViewController {
	@IBOutlet weak var _outlineView: NSOutlineView!
	
	private var _document: Document? = nil
	private var _functionHeader: CFEHeader = CFEHeader(name: "Functions")
	private var _conditionHeader: CFEHeader = CFEHeader(name: "Conditions")
//	private var _functionHeader: String = "Functions"
//	private var _conditionHeader: String = "Conditions"
	
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
	
	@IBAction func onAddFunction(_ sender: NSButton) {
		guard let doc = _document else {
			return
		}
		let newFunc = doc.Story.makeFunction()
		_outlineView.expandItem(_functionHeader)
		_outlineView.reloadItem(_functionHeader, reloadChildren: true)
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newFunc)), byExtendingSelection: false)
	}
	
	@IBAction func onAddCondition(_ sender: NSButton) {
		guard let doc = _document else {
			return
		}
		let newCond = doc.Story.makeCondition()
		_outlineView.expandItem(_conditionHeader)
		_outlineView.reloadItem(_conditionHeader, reloadChildren: true)
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newCond)), byExtendingSelection: false)
	}
	
	@IBAction func onRemoveSelection(_ sender: NSButton) {
		guard let doc = _document else {
			return
		}
		
		if let item = _outlineView.item(atRow: _outlineView.selectedRow) {
			let childIdx = _outlineView.childIndex(forItem: item)
			if -1 == childIdx {
				return
			}
			
			switch item {
			case let asFunc as NVFunction:
				doc.Story.delete(function: asFunc)
			case let asCond as NVCondition:
				doc.Story.delete(condition: asCond)
			default:
				break
			}
			
			let parent = _outlineView.parent(forItem: item)
			_outlineView.removeItems(at: IndexSet(integer: childIdx), inParent: parent, withAnimation: [.effectFade, .slideLeft])
			_outlineView.reloadItem(parent, reloadChildren: false) // if false and remove fails, will not reload it, but if true, it flickers
		}
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
		if let asString = item as? CFEHeader {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("GroupCell"), owner: self)
			(view as? NSTableCellView)?.textField?.stringValue = asString.name
			return view
		}
		
		// handle others
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainCell"), owner: self)
		switch item {
		case let asFunction as NVFunction:
			(view as? NSTableCellView)?.textField?.stringValue = asFunction.Label
			
		case let asCondition as NVCondition:
			(view as? NSTableCellView)?.textField?.stringValue = asCondition.Label
			
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
		if let asString = item as? CFEHeader {
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
		
		if let asString = item as? CFEHeader {
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
		return item is CFEHeader
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is CFEHeader
	}
}
