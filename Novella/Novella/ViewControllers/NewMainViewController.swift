//
//  NewMainViewController.swift
//  Novella
//
//  Created by Daniel Green on 01/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

@IBDesignable
class MyTableTop: NSView {
	@IBInspectable
	var _backgroundColor: NSColor = NSColor.fromHex("#F3F3F3")
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		_backgroundColor.setFill()
		dirtyRect.fill()
	}
}

@IBDesignable
class GraphsTableHeader: NSTableCellView {
	override func draw(_ dirtyRect: NSRect) {
//		NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).setFill()
		NSColor.green.setFill()
		dirtyRect.fill()
		super.draw(dirtyRect)
	}
}

class GraphOutlineRow: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		if !isSelected {
			NSColor.fromHex("#f0f0f0").setFill()
			dirtyRect.fill()
		} else {
		super.draw(dirtyRect)
		}
	}
	
	override func drawSelection(in dirtyRect: NSRect) {
		if self.selectionHighlightStyle != .none {
			NSColor.fromHex("#739cde").setFill()
			dirtyRect.fill()
		}
	}
}

class GraphOutlineView: NSOutlineView {
	override func frameOfOutlineCell(atRow row: Int) -> NSRect {
		return NSRect.zero
	}
	
	override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
		let superFrame = super.frameOfCell(atColumn: column, row: row)
		
		if row == 0 {
			return NSMakeRect(0, superFrame.origin.y, bounds.size.width, superFrame.size.height)
		}
		return superFrame
	}
	
	
}

class NewMainViewController: NSViewController {
	@IBOutlet weak var _graphsOutlineView: NSOutlineView!
	
	let _topLevelItems: [String] = [
		"Graphs"
	]
	
	var _childItems: [String] = [
		"Graph A",
		"Graph B"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_graphsOutlineView.dataSource = self
		_graphsOutlineView.delegate = self
		_graphsOutlineView.floatsGroupRows = false
		_graphsOutlineView.reloadData()
		_graphsOutlineView.expandItem(nil, expandChildren: true)
	}
}

extension NewMainViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return _topLevelItems.count
		}
		return _childItems.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return _topLevelItems[index]
		}
		return _childItems[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return outlineView.parent(forItem: item) == nil
	}
}

extension NewMainViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		let ID = NSUserInterfaceItemIdentifier(rawValue: "myCustomRow")
		var rowView = outlineView.makeView(withIdentifier: ID, owner: self) as? GraphOutlineRow
		if rowView == nil {
			rowView = GraphOutlineRow(frame: NSRect.zero) // auto sizes
			rowView?.identifier = ID
		}
		return rowView
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		if let asString = item as? String {
			return _topLevelItems.contains(asString) ? 25.0 : 25.0
		}
		return 0.0
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if let asString = item as? String {
			return _topLevelItems.contains(asString)
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		if let asString = item as? String {
			if _topLevelItems.contains(asString) {
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? GraphsTableHeader
				view?.textField?.stringValue = asString
			} else {
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextCell"), owner: self) as? NSTableCellView
				view?.textField?.stringValue = asString
			}
		}
		
		return view
	}
}
