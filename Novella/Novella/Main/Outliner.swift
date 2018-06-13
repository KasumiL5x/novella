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
		
		if row == -1 {
			return _blankMenu
		}
		
		self.selectRowIndexes([row], byExtendingSelection: false)
		return _itemMenu
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

class SelectedGraphFancyCell: NSTableCellView {
	@IBOutlet weak var _trashButton: NSButton!
	private var _trashEmptyImage: NSImage?
	private var _trashFullImage: NSImage?
	var _linkable: NVLinkable?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}
	
	private func setup() {
		_trashEmptyImage = NSImage(named: NSImage.Name.trashEmpty)
		_trashFullImage = NSImage(named: NSImage.Name.trashFull)
	}
	
	private func setTrashIcon(_ trash: Bool) {
		_trashButton.image = trash ? _trashFullImage : _trashEmptyImage
	}
	
	@IBAction func onTrash(_ sender: NSButton) {
		if let inTrash = _linkable?.Trashed {
			_linkable!.Trashed = !inTrash
			setTrashIcon(_linkable!.Trashed)
		}
	}
}

class SelectedGraphOutlineView: NSOutlineView {
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
		_blankMenu.addItem(withTitle: "Add...", action: nil, keyEquivalent: "")
		
		_itemMenu = NSMenu()
		_itemMenu.addItem(withTitle: "Toggle Trash", action: #selector(SelectedGraphOutlineView.onItemTrash), keyEquivalent: "")
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let p = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: p)
		
		if row == -1 {
			return _blankMenu
		}
		
		self.selectRowIndexes([row], byExtendingSelection: false)
		return _itemMenu
	}
	
	@objc private func onItemTrash() {
		if var item = self.item(atRow: self.selectedRow) as? NVLinkable {
			let inTrash = item.Trashed
			item.Trashed = !inTrash
		}
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
	private var _graph: NVGraph?
	private var _mvc: MainViewController
	
	private var _dialogImage: NSImage?
	private var _graphImage: NSImage?
	private var _deliveryImage: NSImage?
	private var _linkImage: NSImage?
	
	var Graph: NVGraph? {
		get{ return _graph }
		set{
			_graph = newValue
		}
	}
	
	init(mvc: MainViewController) {
		self._mvc = mvc
		
		self._dialogImage = NSImage(named: NSImage.Name(rawValue: "Dialog"))
		self._graphImage = NSImage(named: NSImage.Name(rawValue: "Graph"))
		self._deliveryImage = NSImage(named: NSImage.Name(rawValue: "Delivery"))
		self._linkImage = NSImage(named: NSImage.Name(rawValue: "Link"))
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let outlineView = (notification.object as! NSOutlineView)
		if let linkableItem = outlineView.item(atRow: outlineView.selectedRow) as? NVLinkable {
			_mvc.getActiveGraph()?.selectNVLinkable(linkable: linkableItem)
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		if row % 2 == 0 {
			rowView.backgroundColor = NSColor.fromHex("#EBEBEB")
		} else {
			rowView.backgroundColor = NSColor.fromHex("#F0F0F0")
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		let customRow = OutlinerTableRowView(frame: NSRect.zero)
		return customRow
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
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FancyCell"), owner: self) as? SelectedGraphFancyCell
		
		switch item {
		case is NVGraph:
			let asGraph = (item as! NVGraph)
			(view as! SelectedGraphFancyCell)._linkable = asGraph
			view?.textField?.stringValue = (asGraph.Trashed ? "🗑 " : "") + asGraph.Name
			view?.imageView?.image = _graphImage
			
		case is NVNode:
			let asNode = (item as! NVNode)
			(view as! SelectedGraphFancyCell)._linkable = asNode
			view?.textField?.stringValue = (asNode.Trashed ? "🗑 " : "") + asNode.Name
			switch item {
			case is NVDialog:
				view?.imageView?.image = _dialogImage
			case is NVDelivery:
				view?.imageView?.image = _deliveryImage
			default:
				break
			}
			
			
		case is NVLink:
			let asLink = (item as! NVLink)
			let from = _mvc.Document.Manager.nameOf(linkable: asLink.Origin)
			let to = _mvc.Document.Manager.nameOf(linkable: asLink.Transfer.Destination)
			view?.textField?.stringValue = "\(from) => \(to)"
			view?.imageView?.image = _linkImage
			
		case is NVBranch:
			let asBranch = (item as! NVBranch)
			let from = _mvc.Document.Manager.nameOf(linkable: asBranch.Origin)
			let toTrue = _mvc.Document.Manager.nameOf(linkable: asBranch.TrueTransfer.Destination)
			let toFalse = _mvc.Document.Manager.nameOf(linkable: asBranch.FalseTransfer.Destination)
			view?.textField?.stringValue = "\(from) => T=\(toTrue); F=\(toFalse)"
			view?.imageView?.image = _linkImage
			
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
			return _mvc.Document.Manager.Story.Graphs.count
		}
		
		return (item as! NVGraph).Graphs.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return _mvc.Document.Manager.Story.Graphs[index]
		}
		return (item as! NVGraph).Graphs[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return (item as! NVGraph).Graphs.count > 0
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
