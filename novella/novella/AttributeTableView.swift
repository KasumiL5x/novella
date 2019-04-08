//
//  AttributeTableView.swift
//  novella
//
//  Created by Daniel Green on 07/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class AttributeTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate {
	var onAdd: (() -> Void)?
	var onDelete: ((String) -> Void)?
	
	private let _menu = NSMenu()
	private var _deleteMenuItem = NSMenuItem()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		sharedInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		sharedInit()
	}
	
	private func sharedInit() {
		self.delegate = self
		
		_menu.autoenablesItems = false
		_menu.addItem(withTitle: "Add", action: #selector(AttributeTableView.onMenuAdd), keyEquivalent: "")
		_deleteMenuItem = NSMenuItem(title: "Delete", action: #selector(AttributeTableView.onMenuDelete), keyEquivalent: "")
		_menu.addItem(_deleteMenuItem)
	}
	
	@objc private func onMenuAdd() {
		onAdd?()
		self.reloadData()
	}
	
	@objc private func onMenuDelete() {
		let idx = self.selectedRow
		if -1 == idx {
			return
		}
		
		if let rowView = self.rowView(atRow: idx, makeIfNecessary: false), let keyCol = rowView.view(atColumn: 0) as? NSTableCellView, let key = keyCol.textField?.stringValue {
			onDelete?(key)
		}
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		_deleteMenuItem.isEnabled = self.selectedRow != -1
		
		return _menu
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSView?
		
		if tableColumn == tableView.tableColumns[0] { // key
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("KeyCell"), owner: self) as? NSTableCellView
		} else { // value
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ValueCell"), owner: self) as? NSTableCellView
		}
		
		return view
	}
}
