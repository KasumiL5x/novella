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
class VariableTabViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet fileprivate weak var _outlineView: NSOutlineView!
	
	// MARK: - Variables -
	private var _manager: NVStoryManager?
	fileprivate var _variableTypeIndices: [String:Int] = [:]
	
	var Manager: NVStoryManager? {
		get{ return _manager }
		set{ _manager = newValue }
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
	
	@IBAction fileprivate func onAddVariable(_ sender: NSButton) {
		if let parent = getSelectedFolder() {
			let variable = _manager!.makeVariable(name: NSUUID().uuidString, type: .boolean)
			try! parent.add(variable: variable)
			_outlineView.reloadData()
		}
	}
	
	@IBAction fileprivate func onAddFolder(_ sender: NSButton) {
		let folder = _manager!.makeFolder(name: NSUUID().uuidString)
		if let parent = getSelectedFolder() {
			try! parent.add(folder: folder)
		} else {
			try! _manager!.Story.add(folder: folder)
		}
		
		_outlineView.reloadData()
	}
	
	@IBAction fileprivate func onRemoveSelected(_ sender: NSButton) {
		if let selectedItem = _outlineView.item(atRow: _outlineView.selectedRow) {
			switch selectedItem {
			case is NVFolder:
				_manager!.delete(folder: selectedItem as! NVFolder, deleteContents: true)
				
			case is NVVariable:
				_manager!.delete(variable: selectedItem as! NVVariable)
				
			default:
				break
			}
			_outlineView.reloadData()
		}
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
extension VariableTabViewController: NSOutlineViewDelegate {
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
extension VariableTabViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			return asFolder.Folders.count + asFolder.Variables.count
			
		case is NVVariable:
			return 0
			
		default:
			return _manager!.Story.Folders.count
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			if index < asFolder.Folders.count {
				return asFolder.Folders[index]
			}
			return asFolder.Variables[index - asFolder.Folders.count]
			
		default:
			return _manager!.Story.Folders[index]
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			return (asFolder.Folders.count + asFolder.Variables.count) > 0
			
		case is NVVariable:
			return false
			
		default:
			return _manager!.Story.Folders.count > 0
		}
	}
}
