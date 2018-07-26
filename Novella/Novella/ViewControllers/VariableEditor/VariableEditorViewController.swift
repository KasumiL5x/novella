//
//  VariableTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 22/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

// MARK: - Custom Cell Views -
// MARK: Type
class VariableTypePopUpCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var _forItem: Any?
	var _outlineView: NSOutlineView?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		guard let asVariable = _forItem as? NVVariable else { return }
		guard let string = sender.selectedItem?.title else { return }
		
		let newDataType = NVDataType.fromString(str: string)
		asVariable.setType(newDataType)
		// reload the item as its data type changed
		_outlineView?.reloadItem(_forItem)
	}
}
// MARK: Initial Value
class VariableInitialValueBoolCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var _forItem: Any?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		guard let asVariable = _forItem as? NVVariable else { return }
		
		let bool = sender.selectedItem?.title == "true" ? true : false
		asVariable.setInitialValue(bool)
	}
}
class VariableInitialValueIntCell: NSTableCellView {
	@IBOutlet weak var _textfield: NSTextField!
	var _forItem: Any?
	
	@IBAction func onTextfieldChanged(_ sender: NSTextField) {
		guard let asVariable = _forItem as? NVVariable else { return }
		
		let int = Int(sender.stringValue) ?? 0
		asVariable.setInitialValue(int)
	}
}
class VariableInitialValueDoubleCell: NSTableCellView {
	@IBOutlet weak var _textfield: NSTextField!
	var _forItem: Any?
	
	@IBAction func onTextfieldChanged(_ sender: NSTextField) {
		guard let asVariable = _forItem as? NVVariable else { return }

		let double = Double(sender.stringValue) ?? 0.0
		asVariable.setInitialValue(double)
	}
}
// MARK: Constant
class VariableConstantBoolCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var _forItem: Any?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		guard let asVariable = _forItem as? NVVariable else { return }
		
		let bool = sender.selectedItem?.title == "true" ? true : false
		asVariable.IsConstant = bool
	}
}

// MARK: - View Controller -
class VariableEditorViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _outlineView: NSOutlineView!
	
	// MARK: - Variables -
	private var _document: NovellaDocument?
	private var _variableTypeIndices: [String:Int] = [:]
	private var _filter: String = ""
	
	// MARK: - Properties -
	var Filter: String {
		get{ return _filter }
		set {
			_filter = newValue
		}
	}
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		_outlineView.backgroundColor = NSColor.fromHex("#F4F5F7")
		
		// map the variable data types to an index in the popup's menu set
		self._variableTypeIndices = [
			NVDataType.boolean.stringValue: 0,
			NVDataType.integer.stringValue: 1,
			NVDataType.double.stringValue: 2
		]
		
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	func setup(doc: NovellaDocument) {
		self._document = doc
		_outlineView.reloadData()
	}
	
	func getSelectedFolder() -> NVFolder? {
		let selectedIndex = _outlineView.selectedRow
		if selectedIndex == -1 {
			return nil
		}
		let selectedItem = _outlineView.item(atRow: selectedIndex)
		
		// if folder is selected, get it
		if selectedItem is NVFolder {
			return selectedItem as? NVFolder
		}
		
		// look up the parent chain until a folder is found
		var parent: Any? = _outlineView.parent(forItem: selectedItem)
		while parent != nil {
			if parent is NVFolder {
				return parent as? NVFolder
			}
			parent = _outlineView.parent(forItem: parent)
		}

		// no folders
		return nil
	}
	
	@IBAction private func onAddVariable(_ sender: NSButton) {
		if let manager = _document?.Manager, let parent = getSelectedFolder() {
			let variable = manager.makeVariable(name: NSUUID().uuidString, type: .boolean)
			parent.add(variable: variable)
			_outlineView.reloadData()
		}
	}
	
	@IBAction private func onAddFolder(_ sender: NSButton) {
		if let manager = _document?.Manager {
			let folder = manager.makeFolder(name: NSUUID().uuidString)
			if let parent = getSelectedFolder() {
				parent.add(folder: folder)
			} else {
				manager.Story.add(folder: folder)
			}
			
			_outlineView.reloadData()
		}
	}
	
	@IBAction private func onRemoveSelected(_ sender: NSButton) {
		if let manager = _document?.Manager, let selectedItem = _outlineView.item(atRow: _outlineView.selectedRow) {
			switch selectedItem {
			case is NVFolder:
				manager.delete(folder: selectedItem as! NVFolder, deleteContents: true)
				
			case is NVVariable:
				manager.delete(variable: selectedItem as! NVVariable)
				
			default:
				break
			}
			_outlineView.reloadData()
		}
	}
	
	@IBAction func onFilterChanged(_ sender: NSSearchField) {
		_filter = sender.stringValue
		_outlineView.reloadData()
	}
	
	// MARK: - Table Callbacks -
	@IBAction func onSynopsisChanged(_ sender: NSTextField) {
		guard let item = _outlineView.item(atRow: _outlineView.selectedRow) else {
			return
		}
		
		switch item {
		case is NVFolder:
			(item as! NVFolder).Synopsis = sender.stringValue
			
		case is NVVariable:
			(item as! NVVariable).Synopsis = sender.stringValue
			
		default:
			break
		}
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let item = _outlineView.item(atRow: _outlineView.selectedRow) else {
			return
		}
		
		switch item {
		case is NVFolder:
			(item as! NVFolder).Name = sender.stringValue
			
		case is NVVariable:
			(item as! NVVariable).Name = sender.stringValue
			
		default:
			break
		}
	}
}

// MARK: - NSOutlineViewDelegate -
extension VariableEditorViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		let customRow = OutlinerTableRowView(frame: NSRect.zero)
		return customRow
	}
	
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		if row % 2 == 0 {
			rowView.backgroundColor = NSColor.fromHex("#FEFEFE")
		} else {
			rowView.backgroundColor = NSColor.fromHex("#F9F9F9")
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameTextCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVFolder).Name
			case is NVVariable:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVVariable).Name
			default:
				(view as! NSTableCellView).textField?.stringValue = "error"
			}
			
		case "SynopsisColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SynopsisTextCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVFolder).Synopsis
			case is NVVariable:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVVariable).Synopsis
			default:
				(view as! NSTableCellView).textField?.stringValue = "error"
			}
			
		case "TypeColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeTextCell"), owner: self) as? NSTableCellView
				(view as! NSTableCellView).textField?.stringValue = "Folder"
			case is NVVariable:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypePopUpCell"), owner: self) as? VariableTypePopUpCell
				let asCustomPopup = view as! VariableTypePopUpCell
				// add menu items mapped from NVDataType (this is only called on creation so should be fine)
				asCustomPopup._popupButton.addItems(withTitles: NVDataType.all.map{$0.stringValue})
				// select item by string (should match!)
				asCustomPopup._popupButton.selectItem(withTitle: (item as! NVVariable).DataType.stringValue)
				// tell the popup which item it is dealing with
				asCustomPopup._forItem = item
				// set which outline view it uses so it can refresh upon change
				asCustomPopup._outlineView = outlineView
			default:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeTextCell"), owner: self) as? NSTableCellView
				(view as! NSTableCellView).textField?.stringValue = "Error"
			}
			
		case "InitialValueColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueTextCell"), owner: self) as? NSTableCellView
			case is NVVariable:
				let asVariable = (item as! NVVariable)
				switch asVariable.DataType {
				case .boolean:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueBoolCell"), owner: self) as? VariableInitialValueBoolCell
					(view as! VariableInitialValueBoolCell)._forItem = item
					(view as! VariableInitialValueBoolCell)._popupButton.selectItem(withTitle: (asVariable.InitialValue as! Bool) ? "true" : "false")
				case .integer:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueIntCell"), owner: self) as? VariableInitialValueIntCell
					(view as! VariableInitialValueIntCell)._forItem = item
					(view as! VariableInitialValueIntCell)._textfield.stringValue = String((asVariable.InitialValue as! Int))
				case .double:
					view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueDoubleCell"), owner: self) as? VariableInitialValueDoubleCell
					(view as! VariableInitialValueDoubleCell)._forItem = item
					(view as! VariableInitialValueDoubleCell)._textfield.stringValue = String((asVariable.InitialValue as! Double))
				}
			default:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueTextCell"), owner: self) as? NSTableCellView
				(view as! NSTableCellView).textField?.stringValue = "Error"
			}
			
		case "ConstantColumn":
			switch item {
			case is NVFolder:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantTextCell"), owner: self) as? NSTableCellView
			case is NVVariable:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantBoolCell"), owner: self) as? VariableConstantBoolCell
				(view as! VariableConstantBoolCell)._forItem = item
				(view as! VariableConstantBoolCell)._popupButton.selectItem(withTitle: (item as! NVVariable).IsConstant ? "true" : "false")
			default:
				view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantTextCell"), owner: self) as? NSTableCellView
				(view as! NSTableCellView).textField?.stringValue = "Error"
			}
			
		default:
			break
		}
		
		return view
	}
}

// MARK: - NSOutlineViewDataSource -
extension VariableEditorViewController: NSOutlineViewDataSource {
	private func filter(variable: NVVariable) -> Bool {
		return _filter.isEmpty || variable.Name.lowercased().contains(_filter.lowercased())
	}
	private func filter(folder: NVFolder) -> Bool {
		if _filter.isEmpty {
			return true
		}
		
		// check self
		if folder.Name.lowercased().contains(_filter.lowercased()) {
			return true
		}
		
		// check all child variables
		for curr in folder.Variables {
			if filter(variable: curr) {
				return true
			}
		}
		
		// check all child folders
		for curr in folder.Folders {
			if filter(folder: curr) {
				return true
			}
		}
		
		// nothing matched
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		var count = 0
		
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			asFolder.Folders.forEach{ (child) in
				if filter(folder: child) {
					count += 1
				}
			}
			asFolder.Variables.forEach{ (child) in
				if filter(variable: child) {
					count += 1
				}
			}
			
		case is NVVariable:
			return 0
			
		default:
			_document?.Manager.Story.Folders.forEach{ (folder) in
				if filter(folder: folder) {
					count += 1
				}
			}
		}
		
		return count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		var indexCount = 0
		
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			for child in asFolder.Folders {
				if filter(folder: child) {
					if indexCount == index {
						return child
					}
					indexCount += 1
				}
			}
			for child in asFolder.Variables {
				if filter(variable: child) {
					if indexCount == index {
						return child
					}
					indexCount += 1
				}
			}
			
		default:
			for folder in _document!.Manager.Story.Folders {
				if filter(folder: folder) {
					if indexCount == index {
						return folder
					}
					indexCount += 1
				}
			}
		}
		
		fatalError("This shouldn't happen!")
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			for child in asFolder.Folders {
				if filter(folder: child) {
					return true
				}
			}
			for child in asFolder.Variables {
				if filter(variable: child) {
					return true
				}
			}
			return false
			
		case is NVVariable:
			return false
			
		default:
			for folder in _document!.Manager.Story.Folders {
				if filter(folder: folder) {
					return true
				}
			}
			return false
		}
	}
}
