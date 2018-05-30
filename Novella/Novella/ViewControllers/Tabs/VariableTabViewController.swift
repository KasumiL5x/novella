//
//  VariableTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 22/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class VariableTypePopUpCell: NSTableCellView {
	@IBOutlet weak var _popupButton: NSPopUpButton!
	var _forItem: Any?
	var _outlineView: NSOutlineView?
	
	@IBAction func onPopupChanged(_ sender: NSPopUpButton) {
		guard let asVariable = _forItem as? NVVariable else {
			return
		}
		guard let string = sender.selectedItem?.title else {
			return
		}
		
		let newDataType = NVDataType.fromString(str: string)
		asVariable.setType(newDataType)
		
		// reload the item as its data type changed
		_outlineView?.reloadItem(_forItem)
	}
}

class VariableTabViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet fileprivate weak var _outlineView: NSOutlineView!
	
	// MARK: - Variables -
	fileprivate var _variableTypeIndices: [String:Int] = [:]
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
			let variable = NVStoryManager.shared.makeVariable(name: NSUUID().uuidString, type: .boolean)
			try! parent.add(variable: variable)
			_outlineView.reloadData()
		}
	}
	
	@IBAction fileprivate func onAddFolder(_ sender: NSButton) {
		let folder = NVStoryManager.shared.makeFolder(name: NSUUID().uuidString)
		if let parent = getSelectedFolder() {
			try! parent.add(folder: folder)
		} else {
			try! NVStoryManager.shared.Story.add(folder: folder)
		}
		
		_outlineView.reloadData()
	}
	
	@IBAction fileprivate func onRemoveSelected(_ sender: NSButton) {
		if let selectedItem = _outlineView.item(atRow: _outlineView.selectedRow) {
			switch selectedItem {
			case is NVFolder:
				NVStoryManager.shared.delete(folder: selectedItem as! NVFolder, deleteContents: true)
				
			case is NVVariable:
				NVStoryManager.shared.delete(variable: selectedItem as! NVVariable)
				
			default:
				break
			}
			_outlineView.reloadData()
		}
	}
}

// MARK: - - NSOutlineViewDelegate -
extension VariableTabViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVFolder).Name
			case is NVVariable:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVVariable).Name
			default:
				(view as! NSTableCellView).textField?.stringValue = "error"
			}
			
		case "SynopsisColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SynopsisCell"), owner: self) as? NSTableCellView
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
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				(view as! NSTableCellView).textField?.stringValue = ""
			case is NVVariable:
				(view as! NSTableCellView).textField?.stringValue = String.fromAny((item as! NVVariable).InitialValue)
			default:
				(view as! NSTableCellView).textField?.stringValue = "error"
			}
			
		case "ConstantColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				(view as! NSTableCellView).textField?.stringValue = ""
			case is NVVariable:
				(view as! NSTableCellView).textField?.stringValue = (item as! NVVariable).IsConstant ? "true" : "false"
			default:
				(view as! NSTableCellView).textField?.stringValue = "error"
			}
			break
			
		default:
			break
		}
		
		return view
	}
}

// MARK: - - NSOutlineViewDataSource -
extension VariableTabViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			return asFolder.Folders.count + asFolder.Variables.count
			
		case is NVVariable:
			return 0
			
		default:
			return NVStoryManager.shared.Story.Folders.count
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
			return NVStoryManager.shared.Story.Folders[index]
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
			return NVStoryManager.shared.Story.Folders.count > 0
		}
	}
}
