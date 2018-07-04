//
//  Outliner.swift
//  Novella
//
//  Created by Daniel Green on 02/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

// MARK: - All Graphs Outliner -
// MARK: Fancy Cell
class AllGraphsFancyCell: NSTableCellView {
	@IBOutlet private weak var _trashButton: NSButton!
	private var _trashEmptyImage: NSImage?
	private var _trashFullImage: NSImage?
	var _graph: NVGraph?
	
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
	
	func setTrashIcon(_ trash: Bool) {
		_trashButton.image = trash ? _trashFullImage : _trashEmptyImage
	}
	
	@IBAction func onTrash(_ sender: NSButton) {
		if let graph = _graph {
			graph.InTrash ? graph.untrash() : graph.trash()
			setTrashIcon(graph.InTrash)
		}
	}
}
// MARK: Outline View
class AllGraphsOutlineView: NSOutlineView {
	private var _mvc: MainViewController?
	private var _blankMenu: NSMenu!
	private var _itemMenu: NSMenu!
	private var _trashMenuItem: NSMenuItem!
	
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
		_itemMenu.addItem(NSMenuItem.separator())
		_trashMenuItem = NSMenuItem(title: "Trash", action: #selector(AllGraphsOutlineView.onItemTrash), keyEquivalent: "")
		_itemMenu.addItem(_trashMenuItem)
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
	@objc private func onItemTrash() {
		if let item = self.item(atRow: self.selectedRow) as? NVGraph {
			item.InTrash ? item.untrash() : item.trash()
			_trashMenuItem.title = item.InTrash ? "Untrash" : "Trash"
		}
	}
}
// MARK: Delegate
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
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FancyCell"), owner: self) as? AllGraphsFancyCell
		let asGraph = item as! NVGraph
		(view as! AllGraphsFancyCell)._graph = asGraph
		(view as! AllGraphsFancyCell).setTrashIcon(asGraph.InTrash)
		view?.textField?.stringValue = asGraph.Name
		
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

// MARK: - Selected Graph Outliner -
// MARK: Fancy Cell
class SelectedGraphFancyCell: NSTableCellView {
	@IBOutlet weak var _trashButton: NSButton!
	private var _trashEmptyImage: NSImage?
	private var _trashFullImage: NSImage?
	var _linkable: NVObject?
	
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
	
	func setTrashIcon(_ trash: Bool) {
		_trashButton.image = trash ? _trashFullImage : _trashEmptyImage
	}
	
	@IBAction func onTrash(_ sender: NSButton) {
		if let obj = _linkable {
			obj.InTrash ? obj.untrash() : obj.trash()
			setTrashIcon(obj.InTrash)
		}
	}
}
// MARK: Outliner
class SelectedGraphOutlineView: NSOutlineView {
	private var _mvc: MainViewController?
	private var _blankMenu: NSMenu!
	private var _itemMenu: NSMenu!
	private var _trashMenuItem: NSMenuItem!
	
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
		_trashMenuItem = NSMenuItem(title: "Trash", action: #selector(SelectedGraphOutlineView.onItemTrash), keyEquivalent: "")
		_itemMenu.addItem(_trashMenuItem)
		
		self.doubleAction = #selector(SelectedGraphOutlineView.onDoubleAction)
	}
	
	override func reloadData() {
		super.reloadData()
		self.expandItem(nil, expandChildren: true)
	}
	
	@objc private func onDoubleAction() {
		if let linkableItem = self.item(atRow: self.selectedRow) as? NVObject {
			_mvc?.getActiveGraph()?.selectNVLinkable(linkable: linkableItem)
		}
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
		if let item = self.item(atRow: self.selectedRow) as? NVObject {
			item.InTrash ? item.untrash() : item.trash()
			_trashMenuItem.title = item.InTrash ? "Untrash" : "Trash"
		}
	}
}

class OutlinerTableRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if isGroupRowStyle {
			isSelected ? NSColor.fromHex("#739cde").setFill() : NSColor.fromHex("#f7f7f7").setFill()
			dirtyRect.fill()
		} else {
			if isSelected {
				NSColor.fromHex("#739cde").setFill()
				dirtyRect.fill()
			}
		}
		
	}
}
// MARK: Delegate
class SelectedGraphDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
	private var _graph: NVGraph?
	private var _mvc: MainViewController
	
	private var _dialogImage: NSImage?
	private var _graphImage: NSImage?
	private var _deliveryImage: NSImage?
	private var _linkImage: NSImage?
	
	private var _filter: String
	
	private var _topLevel: [String]
	// TODO: How to make elements part of the top-level below? shouldn't be hard but i need to think or find a sample.
	
	var Graph: NVGraph? {
		get{ return _graph }
		set{
			_graph = newValue
		}
	}
	var Filter: String {
		get{ return _filter }
		set{
			_filter = newValue
		}
	}
	
	init(mvc: MainViewController) {
		self._mvc = mvc
		
		self._dialogImage = NSImage(named: NSImage.Name(rawValue: "Dialog"))
		self._graphImage = NSImage(named: NSImage.Name(rawValue: "Graph"))
		self._deliveryImage = NSImage(named: NSImage.Name(rawValue: "Delivery"))
		self._linkImage = NSImage(named: NSImage.Name(rawValue: "Link"))
		
		self._filter = ""
		
		self._topLevel = [
			"Nodes",
			"Graphs",
			"Links"
		]
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
	
	private func filter(node: NVNode) -> Bool {
		return _filter.isEmpty || node.Name.lowercased().contains(_filter.lowercased())
	}
	private func filter(graph: NVGraph) -> Bool {
		return _filter.isEmpty || graph.Name.lowercased().contains(_filter.lowercased())
	}
	private func filter(link: NVBaseLink) -> Bool {
		if _filter.isEmpty {
			return true
		}
		
		switch link {
		case is NVLink:
			let asLink = link as! NVLink
			if asLink.Origin.Name.lowercased().contains(_filter.lowercased()) {
				return true
			}
			if let dest = asLink.Transfer.Destination {
				if dest.Name.lowercased().contains(_filter.lowercased()) {
					return true
				}
			}
			
		case is NVBranch:
			let asBranch = link as! NVBranch
			if asBranch.Origin.Name.lowercased().contains(_filter.lowercased()) {
				return true
			}
			if let trueDest = asBranch.TrueTransfer.Destination {
				if trueDest.Name.lowercased().contains(_filter.lowercased()) {
					return true
				}
			}
			if let falseDest = asBranch.FalseTransfer.Destination {
				if falseDest.Name.lowercased().contains(_filter.lowercased()) {
					return true
				}
			}
			
		default:
			print("SelecterGraphDelegate tried to filter an unhandled NVBaseLink: \(link).")
		}
		
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if nil == _graph {
			return 0
		}
		
		if let asString = item as? String {
			switch asString {
			case _topLevel[0]:
				var count = 0
				_graph!.Nodes.forEach { (node) in
					if filter(node: node) {
						count += 1
					}
				}
				return count
				
			case _topLevel[1]:
				var count = 0
				_graph!.Graphs.forEach { (graph) in
					if filter(graph: graph) {
						count += 1
					}
				}
				return count
			case _topLevel[2]:
				var count = 0
				_graph!.Links.forEach { (link) in
					if filter(link: link) {
						count += 1
					}
				}
				return count
			default:
				break
			}
		}
		
		return _topLevel.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let asString = item as? String {
			var indexCount = 0
			switch asString {
			case _topLevel[0]:
				for node in _graph!.Nodes {
					if filter(node: node) {
						if indexCount == index {
							return node
						}
						indexCount += 1
					}
				}
				
			case _topLevel[1]:
				for graph in _graph!.Graphs {
					if filter(graph: graph) {
						if indexCount == index {
							return graph
						}
						indexCount += 1
					}
				}
				
			case _topLevel[2]:
				for link in _graph!.Links {
					if filter(link: link) {
						if indexCount == index {
							return link
						}
						indexCount += 1
					}
				}
				
			default:
				break
			}
		}
		
		return _topLevel[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is String
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is String
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		if let asString = item as? String {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GroupCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = asString
		} else {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FancyCell"), owner: self) as? SelectedGraphFancyCell
		
			switch item {
			case is NVGraph:
				let asGraph = (item as! NVGraph)
				(view as! SelectedGraphFancyCell)._linkable = asGraph
				(view as! SelectedGraphFancyCell).setTrashIcon(asGraph.InTrash)
				view?.textField?.stringValue = asGraph.Name
				view?.imageView?.image = _graphImage
				
			case is NVNode:
				let asNode = (item as! NVNode)
				(view as! SelectedGraphFancyCell)._linkable = asNode
				(view as! SelectedGraphFancyCell).setTrashIcon(asNode.InTrash)
				view?.textField?.stringValue = asNode.Name
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
				(view as! SelectedGraphFancyCell).setTrashIcon(asLink.InTrash)
				let from = _mvc.Document.Manager.nameOf(linkable: asLink.Origin)
				let to = _mvc.Document.Manager.nameOf(linkable: asLink.Transfer.Destination)
				view?.textField?.stringValue = "\(from) => \(to)"
				view?.imageView?.image = _linkImage
				
			case is NVBranch:
				let asBranch = (item as! NVBranch)
				(view as! SelectedGraphFancyCell).setTrashIcon(asBranch.InTrash)
				let from = _mvc.Document.Manager.nameOf(linkable: asBranch.Origin)
				let toTrue = _mvc.Document.Manager.nameOf(linkable: asBranch.TrueTransfer.Destination)
				let toFalse = _mvc.Document.Manager.nameOf(linkable: asBranch.FalseTransfer.Destination)
				view?.textField?.stringValue = "\(from) => T=\(toTrue); F=\(toFalse)"
				view?.imageView?.image = _linkImage
				
			default:
				view?.textField?.stringValue = "ERROR"
			}
		}
		
		return view
	}
	
}
