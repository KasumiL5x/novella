//
//  EntitiesEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 16/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class EntityTagsTableView: NSTableView, NSTableViewDelegate {
	private var _menu: NSMenu!
	private var _deleteMenuItem: NSMenuItem!
	
	var onAdd: (() -> Void)?
	var onDelete: ((String) -> Void)?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialSetup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialSetup()
	}
	
	private func initialSetup() {
		_menu = NSMenu()
		_menu.autoenablesItems = false
		_menu.addItem(withTitle: "Add Tag", action: #selector(EntityTagsTableView.onMenuAdd), keyEquivalent: "")
		_deleteMenuItem = NSMenuItem(title: "Delete Selection", action: #selector(EntityTagsTableView.onMenuDelete), keyEquivalent: "")
		_deleteMenuItem.isEnabled = false
		_menu.addItem(_deleteMenuItem)
		
		self.delegate = self
	}
	
	@objc private func onMenuAdd() {
		onAdd?()
	}
	
	@objc private func onMenuDelete() {
		if let rowView = self.rowView(atRow: self.selectedRow, makeIfNecessary: false), let col = rowView.view(atColumn: 0) as? NSTableCellView, let key = col.textField?.stringValue {
			onDelete?(key)
		}
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: mousePoint)
		if row != -1 {
			self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			_deleteMenuItem.isEnabled = true
		} else {
			_deleteMenuItem.isEnabled = false
		}
		
		return _menu
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSView?
		view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("LabelCell"), owner: self) as? NSTableCellView
		return view
	}
}

class EntitiesEditorOutlineView: NSOutlineView {
	private var _menu: NSMenu!
	private var _deleteMenuItem: NSMenuItem!
	
	var onNew: (() -> Void)?
	var onDelete: (() -> Void)?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		_menu = NSMenu()
		_menu.autoenablesItems = false
		_menu.addItem(withTitle: "New Entity", action: #selector(EntitiesEditorOutlineView.onMenuNew), keyEquivalent: "")
		_deleteMenuItem = NSMenuItem(title: "Delete Selection", action: #selector(EntitiesEditorOutlineView.onMenuDelete), keyEquivalent: "")
		_deleteMenuItem.isEnabled = false
		_menu.addItem(_deleteMenuItem)
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: mousePoint)
		if row != -1 {
			self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			_deleteMenuItem.isEnabled = true
		} else {
			_deleteMenuItem.isEnabled = false
		}
		
		return _menu
	}
	
	@objc private func onMenuNew() {
		onNew?()
	}
	
	@objc private func onMenuDelete() {
		onDelete?()
	}
}

class EntitiesEditorViewController: NSViewController {
	@IBOutlet weak private var _entitiesOutlineView: EntitiesEditorOutlineView!
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _description: NSTextField!
	@IBOutlet weak private var _entityTagsTableView: EntityTagsTableView!
	//
	@IBOutlet private var _tagsArrayController: NSArrayController!
	
	private var _document: Document? = nil
	private var _selectedEntity: NVEntity? = nil
	
	override func viewDidLoad() {
		_entitiesOutlineView.delegate = self
		_entitiesOutlineView.dataSource = self
		_entitiesOutlineView.reloadData()
		
		_entitiesOutlineView.onNew = {
			self.addNewEntity()
		}
		_entitiesOutlineView.onDelete = {
			self.deleteSelection()
		}
		
		_entityTagsTableView.onAdd = {
			if nil == self._tagsArrayController.content {
				return
			}
			self._tagsArrayController.addObject(NVUtil.randomString(length: 10))
		}
		_entityTagsTableView.onDelete = { (key) in
			if nil == self._tagsArrayController.content {
				return
			}
			self._tagsArrayController.remove(key)
		}
	}
	
	func setup(doc: Document) {
		_document = doc
	}
	
	private func addNewEntity() {
		guard let doc = _document else {
			return
		}
		let newEntity = doc.Story.makeEntity()
		_entitiesOutlineView.reloadData()
		_entitiesOutlineView.selectRowIndexes(IndexSet(integer: _entitiesOutlineView.row(forItem: newEntity)), byExtendingSelection: false)
		
		// should be the new item
		setupFor(entity: _entitiesOutlineView.item(atRow: _entitiesOutlineView.selectedRow) as? NVEntity)
	}
	
	private func deleteSelection() {
		guard let doc = _document else {
			return
		}
		
		if let item = _entitiesOutlineView.item(atRow: _entitiesOutlineView.selectedRow) as? NVEntity {
			doc.Story.delete(entity: item)
			_entitiesOutlineView.reloadData()
			
			// could be nil or a nearby item
			setupFor(entity: _entitiesOutlineView.item(atRow: _entitiesOutlineView.selectedRow) as? NVEntity)
		}
	}
	
	private func setupFor(entity: NVEntity?) {
		if let entity = entity {
			_selectedEntity = entity
			_label.stringValue = entity.Label
			_description.stringValue = entity.Description
			_tagsArrayController.content = entity.Tags
		} else { // "reset"
			_selectedEntity = nil
			_label.stringValue = ""
			_description.stringValue = ""
			_tagsArrayController.content = nil
		}
	}
	
	@IBAction func selectedEntityDidChange(_ sender: EntitiesEditorOutlineView) {
		guard let item = sender.item(atRow: sender.selectedRow) as? NVEntity else {
			setupFor(entity: nil)
			return
		}
		setupFor(entity: item)
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		if let entity = _selectedEntity {
			entity.Label = sender.stringValue
			_entitiesOutlineView.reloadItem(entity) // name changed, reload it
		}
	}
	
	@IBAction func descriptionDidChange(_ sender: NSTextField) {
		_selectedEntity?.Label = sender.stringValue
	}
}
extension EntitiesEditorViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return CustomTableRowView(frame: NSRect.zero)
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = (row % 2 == 0) ? NSColor(named: "NVTableRowEven")! : NSColor(named: "NVTableRowOdd")!
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		guard let entity = item as? NVEntity else {
			return nil
		}
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LabelCell"), owner: self) as? NSTableCellView
		(view as? NSTableCellView)?.textField?.stringValue = entity.Label.isEmpty ? "Unnamed" : entity.Label
		
		return view
	}
}
extension EntitiesEditorViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if nil == item {
			return _document?.Story.Entities.count ?? 0
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return _document!.Story.Entities[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
}
