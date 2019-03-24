//
//  VariablesEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 24/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class VariablesEditorNameCell: NSTableCellView {
	var variable: NVVariable?
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		variable?.Name = sender.stringValue
	}
}

class VariablesEditorConstantCell: NSTableCellView {
	@IBOutlet weak var _constant: NSButton!
	
	var variable: NVVariable?
	
	@IBAction func onConstantChanged(_ sender: NSButton) {
		variable?.Constant = sender.state == .on
	}
}

class VariablesEditorTypeCell: NSTableCellView {
	@IBOutlet weak private var _type: NSPopUpButton!
	var variable: NVVariable?
	var outlineView: NSOutlineView?
	
	func setup() {
		guard let variable = variable else {
			return
		}
		switch variable.Value.Raw.type {
		case .boolean:
			_type.selectItem(withTitle: "Boolean")
		case .integer:
			_type.selectItem(withTitle: "Integer")
		case .double:
			_type.selectItem(withTitle: "Double")
		}
	}
	
	@IBAction func onTypeChanged(_ sender: NSPopUpButton) {
		guard let variable = variable else {
			return
		}
		
		switch sender.selectedItem?.title {
		case "Boolean":
			variable.set(value: NVValue(.boolean(variable.Value.Raw.asBool)))
		case "Integer":
			variable.set(value: NVValue(.integer(variable.Value.Raw.asInt)))
		case "Double":
			variable.set(value: NVValue(.double(variable.Value.Raw.asDouble)))
		default:
			break
		}
		
		outlineView?.reloadItem(variable)
	}
}

class VariablesEditorValueBoolCell: NSTableCellView {
	@IBOutlet weak private var _bool: NSPopUpButton!
	var variable: NVVariable?
	
	func setup() {
		guard let variable = variable else {
			return
		}
		_bool.selectItem(withTitle: variable.Value.Raw.asBool ? "True" : "False")
	}
	
	@IBAction func onBoolChanged(_ sender: NSPopUpButton) {
		variable?.set(value: NVValue(.boolean(sender.stringValue == "True")))
	}
}

class VariablesEditorValueIntCell: NSTableCellView {
	@IBOutlet weak private var _int: NSTextField!
	var variable: NVVariable?
	
	func setup() {
		guard let variable = variable else {
			return
		}
		_int.stringValue = "\(variable.Value.Raw.asInt)"
	}
	
	@IBAction func onIntChanged(_ sender: NSTextField) {
		variable?.set(value: NVValue(.integer(Int32(sender.stringValue) ?? 0)))
	}
}

class VariablesEditorValueDoubleCell: NSTableCellView {
	@IBOutlet weak private var _double: NSTextField!
	var variable: NVVariable?
	
	func setup() {
		guard let variable = variable else {
			return
		}
		_double.stringValue = "\(variable.Value.Raw.asDouble)"
	}
	
	@IBAction func onDoubleChanged(_ sender: NSTextField) {
		variable?.set(value: NVValue(.double(Double(sender.stringValue) ?? 0.0)))
	}
}

class VariablesEditorOutlineView: NSOutlineView {
	private var _menu: NSMenu!
	private var _deleteMenuItem: NSMenuItem!
	
	var onNewVariable: (() -> Void)?
	var onDeleteSelection: (() -> Void)?
	
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
		_menu.addItem(withTitle: "New Variable", action: #selector(VariablesEditorOutlineView.onMenuNewVariable), keyEquivalent: "")
		_deleteMenuItem = NSMenuItem(title: "Delete Selection", action: #selector(VariablesEditorOutlineView.onMenuDeleteSelection), keyEquivalent: "")
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
	
	@objc private func onMenuNewVariable() {
		onNewVariable?()
	}
	
	@objc private func onMenuDeleteSelection() {
		onDeleteSelection?()
	}
}

class VariablesEditorViewController: NSViewController {
	@IBOutlet weak private var _outlineView: VariablesEditorOutlineView!
	
	private var _document: Document? = nil
	
	override func viewDidLoad() {
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
		
		_outlineView.onNewVariable = {
			self.addNewVariable()
		}
		_outlineView.onDeleteSelection = {
			self.deleteSelection()
		}
	}
	
	public func setup(doc: Document) {
		_document = doc
	}
	
	override func viewDidAppear() {
		_outlineView.reloadData()
	}
	
	private func addNewVariable() {
		guard let doc = _document else {
			return
		}
		let newVar = doc.Story.makeVariable()
		_outlineView.reloadData()
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newVar)), byExtendingSelection: false)
	}
	
	private func deleteSelection() {
		guard let doc = _document else {
			return
		}
		
		if let item = _outlineView.item(atRow: _outlineView.selectedRow) as? NVVariable {
			doc.Story.delete(variable: item)
			_outlineView.reloadData()
		}
	}
}

extension VariablesEditorViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return CustomTableRowView(frame: NSRect.zero)
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = (row % 2 == 0) ? NSColor(named: "NVTableRowEven")! : NSColor(named: "NVTableRowOdd")!
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		guard let variable = item as? NVVariable else {
			return nil
		}
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? VariablesEditorNameCell
			(view as? VariablesEditorNameCell)?.variable = variable
			(view as? VariablesEditorNameCell)?.textField?.stringValue = variable.Name
			break
			
		case "ConstantColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantCell"), owner: self) as? VariablesEditorConstantCell
			(view as? VariablesEditorConstantCell)?.variable = variable
			(view as? VariablesEditorConstantCell)?._constant.state = variable.Constant ? .on : .off
			break
			
		case "TypeColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeCell"), owner: self) as? VariablesEditorTypeCell
			(view as? VariablesEditorTypeCell)?.outlineView = outlineView
			(view as? VariablesEditorTypeCell)?.variable = variable
			(view as? VariablesEditorTypeCell)?.setup()
			break
			
		case "ValueColumn":
			
			// as above, create a new class for each of the three below and set based on the type.
			// look at old project's "InitialValueColumn" and related classes for an example.
			
			switch variable.Value.Raw.type {
			case .boolean:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueBoolCell"), owner: self) as? VariablesEditorValueBoolCell
				(view as? VariablesEditorValueBoolCell)?.variable = variable
				(view as? VariablesEditorValueBoolCell)?.setup()
			case .integer:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueIntCell"), owner: self) as? VariablesEditorValueIntCell
				(view as? VariablesEditorValueIntCell)?.variable = variable
				(view as? VariablesEditorValueIntCell)?.setup()
			case .double:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueDoubleCell"), owner: self) as? VariablesEditorValueDoubleCell
				(view as? VariablesEditorValueDoubleCell)?.variable = variable
				(view as? VariablesEditorValueDoubleCell)?.setup()
			}
			break
			
		default:
			break
		}
		
		return view
	}
}

extension VariablesEditorViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return _document?.Story.Variables.count ?? 0
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return _document!.Story.Variables[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
}
