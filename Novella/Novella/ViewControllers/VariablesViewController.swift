//
//  VariablesViewController.swift
//  novella
//
//  Created by dgreen on 13/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class VariablesTableRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if isGroupRowStyle {
			isSelected ? Colors.TableGroupRowSelected.setFill() : Colors.TableGroupRowDeselected.setFill()
			dirtyRect.fill()
		} else {
			if isSelected {
				Colors.TableRowSelected.setFill()
				dirtyRect.fill()
			}
		}
	}
}

class VariablesNameTextCell: NSTableCellView {
	var VariableItem: NVVariable?
	var FolderItem: NVFolder?
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		VariableItem?.Name = sender.stringValue
		FolderItem?.Name = sender.stringValue
	}
}

class VariablesSynopsisTextCell: NSTableCellView {
	var VariableItem: NVVariable?
	var FolderItem: NVFolder?
	
	@IBAction func onSynopsisChanged(_ sender: NSTextField) {
		VariableItem?.Synopsis = sender.stringValue
		FolderItem?.Synopsis = sender.stringValue
	}
}

class VariablesTypePopUpCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var Item: NVVariable?
	var OutlineView: NSOutlineView?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		guard let item = Item else {
			return
		}
		
		switch sender.selectedItem?.title {
		case NVValueType.boolean.toString:
			item.InitialValue = NVValue(.boolean(item.InitialValue.Raw.asBool))
		case NVValueType.integer.toString:
			item.InitialValue = NVValue(.integer(item.InitialValue.Raw.asInt))
		case NVValueType.double.toString:
			item.InitialValue = NVValue(.double(item.InitialValue.Raw.asDouble))
		default:
			break
		}
		
		OutlineView?.reloadItem(item)
	}
}

class VariablesInitialValueBoolCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var Item: NVVariable?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		Item?.InitialValue = NVValue(.boolean(sender.stringValue == "True"))
	}
}

class VariablesInitialValueIntCell: NSTableCellView {
	@IBOutlet weak var _textfield: NSTextField!
	var Item: NVVariable?
	
	@IBAction func onTextfieldChanged(_ sender: NSTextField) {
		let intValue = Int32(sender.stringValue) ?? 0
		Item?.InitialValue = NVValue(.integer(intValue))
	}
}

class VariablesInitialValueDoubleCell: NSTableCellView {
	@IBOutlet weak var _textfield: NSTextField!
	var Item: NVVariable?
	
	@IBAction func onTextfieldChanged(_ sender: NSTextField) {
		let doubleValue = Double(sender.stringValue) ?? 0.0
		Item?.InitialValue = NVValue(.double(doubleValue))
	}
}

class VariablesConstantBoolCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var Item: NVVariable?
	var OutlineView: NSOutlineView?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		Item?.Constant = sender.selectedItem?.title == "True"
	}
}

class VariablesViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _outlineView: NSOutlineView!
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			_outlineView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	override func viewDidAppear() {
		_outlineView.reloadData()
	}
	
	@IBAction func onToolbarButton(_ sender: NSSegmentedControl) {
		guard let doc = Doc, let parentFolder = getSelectedFolder() else {
			return
		}
		
		switch sender.selectedSegment {
		case 0: // add folder
			parentFolder.add(folder: doc.Story.makeFolder(name: NSUUID().uuidString))
			_outlineView.reloadData()
		case 1: // add variable
			parentFolder.add(variable: doc.Story.makeVariable(name: NSUUID().uuidString))
			_outlineView.reloadData()
		case 2: // remove (selected)
			print("Removing folders and variables not yet implemented.")
		default:
			break
		}
	}
	
	private func getSelectedFolder() -> NVFolder? {
		guard let item = _outlineView.item(atRow: _outlineView.selectedRow) else {
			return nil
		}
		
		// folder directly selected
		if item is NVFolder {
			return (item as! NVFolder)
		}
		
		// look up chain until folder is found
		var parent: Any? = _outlineView.parent(forItem: item)
		while parent != nil {
			if parent is NVFolder {
				return (parent as! NVFolder)
			}
			parent = _outlineView.parent(forItem: parent)
		}
		
		return nil
	}
}

extension VariablesViewController: NSOutlineViewDelegate {
	// custom row class
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return VariablesTableRowView(frame: NSRect.zero)
	}
	
	// color odd/even rows
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		if row % 2 == 0 {
			rowView.backgroundColor = Colors.TableRowEven
		} else {
			rowView.backgroundColor = Colors.TableRowOdd
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameTextCell"), owner: self) as? VariablesNameTextCell
			switch item {
			case let asFolder as NVFolder:
				(view as? VariablesNameTextCell)?.FolderItem = asFolder
				(view as? VariablesNameTextCell)?.textField?.stringValue = asFolder.Name
			case let asVariable as NVVariable:
				(view as? VariablesNameTextCell)?.VariableItem = asVariable
				(view as? VariablesNameTextCell)?.textField?.stringValue = asVariable.Name
			default:
				break
			}
			
		case "SynopsisColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SynopsisTextCell"), owner: self) as? VariablesSynopsisTextCell
			switch item {
			case let asFolder as NVFolder:
				(view as? VariablesSynopsisTextCell)?.FolderItem = asFolder
				(view as? VariablesSynopsisTextCell)?.textField?.stringValue = asFolder.Synopsis
			case let asVariable as NVVariable:
				(view as? VariablesSynopsisTextCell)?.VariableItem = asVariable
				(view as? VariablesSynopsisTextCell)?.textField?.stringValue = asVariable.Synopsis
			default:
				break
			}
			
		case "TypeColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeTextCell"), owner: self) as? NSTableCellView
				(view as? NSTableCellView)?.textField?.stringValue = "Folder"
			case let asVariable as NVVariable:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypePopUpCell"), owner: self) as? VariablesTypePopUpCell
				(view as? VariablesTypePopUpCell)?.Item = asVariable
				(view as? VariablesTypePopUpCell)?.OutlineView = outlineView
				(view as? VariablesTypePopUpCell)?._popupButton.addItems(withTitles: NVValueType.all.map{$0.toString})
				(view as? VariablesTypePopUpCell)?._popupButton.selectItem(withTitle: asVariable.InitialValue.Raw.type.toString)
			default:
				break
			}
			
		case "InitialValueColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueTextCell"), owner: self) as? NSTableCellView
				(view as? NSTableCellView)?.textField?.stringValue = ""
			case let asVariable as NVVariable:
				switch asVariable.InitialValue.Raw.type {
				case .boolean:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueBoolCell"), owner: self) as? VariablesInitialValueBoolCell
					(view as? VariablesInitialValueBoolCell)?.Item = asVariable
					(view as? VariablesInitialValueBoolCell)?._popupButton.selectItem(withTitle: asVariable.InitialValue.Raw.asBool ? "True" : "False")
				case .integer:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueIntCell"), owner: self) as? VariablesInitialValueIntCell
					(view as? VariablesInitialValueIntCell)?.Item = asVariable
					(view as? VariablesInitialValueIntCell)?.textField?.stringValue = String(asVariable.InitialValue.Raw.asInt)
				case .double:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueDoubleCell"), owner: self) as? VariablesInitialValueDoubleCell
					(view as? VariablesInitialValueDoubleCell)?.Item = asVariable
					(view as? VariablesInitialValueDoubleCell)?.textField?.stringValue = String(asVariable.InitialValue.Raw.asDouble)
				}
			default:
				break
			}
			
		case "ConstantColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantTextCell"), owner: self) as? NSTableCellView
				(view as? NSTableCellView)?.textField?.stringValue = ""
			case let asVariable as NVVariable:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantBoolCell"), owner: self) as? VariablesConstantBoolCell
				(view as? VariablesConstantBoolCell)?.Item = asVariable
				(view as? VariablesConstantBoolCell)?.OutlineView = outlineView
				(view as? VariablesConstantBoolCell)?._popupButton.selectItem(withTitle: asVariable.Constant ? "True" : "False")
			default:
				break
			}
			
		default:
			break
		}
		
		return view
	}
}

extension VariablesViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item {
		case let asFolder as NVFolder:
			return asFolder.Folders.count + asFolder.Variables.count
		case is NVVariable:
			return 0
		default:
			return Doc != nil ? 1 : 0 // main folder
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		switch item {
		case let asFolder as NVFolder:
			if index < asFolder.Folders.count {
				return asFolder.Folders[index]
			}
			return asFolder.Variables[index]
			
		default:
			return Doc!.Story.MainFolder! // valid at this point
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case let asFolder as NVFolder:
			return (asFolder.Folders.count + asFolder.Variables.count) > 0
			
		default:
			return false
		}
	}
}
