//
//  OutlinerDelegateDataSource.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class AllGraphsOutlineView: NSOutlineView {
	private var _mvc: MainViewController?
	private var _blankMenu: NSMenu!
	private var _itemMenu: NSMenu!
	
	var MVC: MainViewController? {
		get{ return _mvc }
		set{ _mvc = newValue }
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		_blankMenu = NSMenu()
		_blankMenu.addItem(withTitle: "Add Story Graph", action: #selector(AllGraphsOutlineView.onBlankAdd), keyEquivalent: "")
		
		_itemMenu = NSMenu()
		_itemMenu.addItem(withTitle: "Add Sub Graph", action: #selector(AllGraphsOutlineView.onItemAdd), keyEquivalent: "")
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let p = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: p)
		
		return (row == -1) ? _blankMenu : _itemMenu
	}
	
	@objc private func onBlankAdd() {
		_mvc?.addGraph(parent: nil)
	}
	
	@objc private func onItemAdd() {
		if let parent = self.item(atRow: self.selectedRow) as? NVGraph {
			_mvc?.addGraph(parent: parent)
		}
	}
}

class SelectedGraphOutlineView: NSOutlineView {
	private var _mvc: MainViewController?
	private var _blankMenu: NSMenu!
	
	var MVC: MainViewController? {
		get{ return _mvc }
		set{ _mvc = newValue }
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		_blankMenu = NSMenu()
		_blankMenu.addItem(withTitle: "Add...", action: nil, keyEquivalent: "")
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let p = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: p)
		
		if row == -1 {
			return _blankMenu
		}
		
		return nil
	}
}

class OutlinerTableRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		if isSelected {
			NSColor.fromHex("#739cde").setFill()
			dirtyRect.fill()
		}
	}
}

class SelectedGraphDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
	fileprivate var _graph: NVGraph?
	fileprivate var _mvc: MainViewController
	
	var Graph: NVGraph? {
		get{ return _graph }
		set{
			_graph = newValue
		}
	}
	
	init(mvc: MainViewController) {
		self._mvc = mvc
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if nil == _graph {
			return 0
		}
		
		if item == nil {
			return _graph!.Nodes.count +
			       _graph!.Graphs.count +
			       _graph!.Links.count
		}
		
		return 0 // everything else
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if index < _graph!.Nodes.count {
			return _graph!.Nodes[index]
		}
		var offset = _graph!.Nodes.count
		
		if index < (offset + _graph!.Graphs.count) {
			return _graph!.Graphs[index - offset]
		}
		offset += _graph!.Graphs.count
		
		if index < (offset + _graph!.Links.count) {
			return _graph!.Links[index - offset]
		}
		offset += _graph!.Links.count
		
		fatalError("Shouldn't ever happen.")
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextCell"), owner: self) as? NSTableCellView
		
		switch item {
		case is NVGraph:
			view?.textField?.stringValue = (item as! NVGraph).Name
			
		case is NVNode:
			view?.textField?.stringValue = (item as! NVNode).Name
			
		case is NVLink:
			let from = NVStoryManager.shared.nameOf(linkable: (item as! NVLink).Origin)
			let to = NVStoryManager.shared.nameOf(linkable: (item as! NVLink).Transfer.Destination)
			view?.textField?.stringValue = "\(from) => \(to)"
			
		case is NVBranch:
			let from = NVStoryManager.shared.nameOf(linkable: (item as! NVBranch).Origin)
			let toTrue = NVStoryManager.shared.nameOf(linkable: (item as! NVBranch).TrueTransfer.Destination)
			let toFalse = NVStoryManager.shared.nameOf(linkable: (item as! NVBranch).FalseTransfer.Destination)
			view?.textField?.stringValue = "\(from) => T=\(toTrue); F=\(toFalse)"
			
		default:
			view?.textField?.stringValue = "ERROR"
		}
		
		return view
	}
	
}

class AllGraphsDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
	fileprivate var _mvc: MainViewController
	
	init(mvc: MainViewController) {
		self._mvc = mvc
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let outlineView = (notification.object as! NSOutlineView)
		
		_mvc.setSelectedGraph(graph: outlineView.item(atRow: outlineView.selectedRow) as? NVGraph)
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return NVStoryManager.shared.Graphs.count
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return NVStoryManager.shared.Graphs[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextCell"), owner: self) as? NSTableCellView
		view?.textField?.stringValue = (item as! NVGraph).Name
		
		return view
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = NSColor.fromHex("#F0F0F0")
	}
	
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		let customRow = OutlinerTableRowView(frame: NSRect.zero)
		return customRow
	}
}
