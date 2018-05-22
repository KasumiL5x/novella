//
//  VariableTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 22/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class VariableTabViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _outlineView: NSOutlineView!
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory?
	
	// MARK: - - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	func setup(story: NVStory) {
		_story = story
		if isViewLoaded {
			_outlineView.reloadData()
		}
	}
	
	@IBAction fileprivate func onAddVariable(_ sender: NSButton) {
	}
	
	@IBAction fileprivate func onAddFolder(_ sender: NSButton) {
	}
	
	@IBAction fileprivate func onRemoveSelected(_ sender: NSButton) {
	}
}

// MARK: - - NSOutlineViewDelegate -
extension VariableTabViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView?
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				view?.textField?.stringValue = (item as! NVFolder).Name
			case is NVVariable:
				view?.textField?.stringValue = (item as! NVVariable).Name
			default:
				view?.textField?.stringValue = "error"
			}
			
		case "SynopsisColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SynopsisCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				view?.textField?.stringValue = (item as! NVFolder).Synopsis
			case is NVVariable:
				view?.textField?.stringValue = (item as! NVVariable).Synopsis
			default:
				view?.textField?.stringValue = "error"
			}
			
		case "TypeColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				view?.textField?.stringValue = "Folder"
			case is NVVariable:
				view?.textField?.stringValue = (item as! NVVariable).DataType.stringValue
			default:
				view?.textField?.stringValue = "error"
			}
			
		case "InitialValueColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "InitialValueCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				view?.textField?.stringValue = ""
			case is NVVariable:
				view?.textField?.stringValue = String.fromAny((item as! NVVariable).InitialValue)
			default:
				view?.textField?.stringValue = "error"
			}
			
		case "ConstantColumn":
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConstantCell"), owner: self) as? NSTableCellView
			switch item {
			case is NVFolder:
				view?.textField?.stringValue = ""
			case is NVVariable:
				view?.textField?.stringValue = (item as! NVVariable).IsConstant ? "true" : "false"
			default:
				view?.textField?.stringValue = "error"
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
		if _story == nil {
			return 0
		}
		
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			return asFolder.Folders.count + asFolder.Variables.count
			
		case is NVVariable:
			return 0
			
		default:
			return _story!.Folders.count
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if _story == nil {
			return ""
		}
		
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			if index < asFolder.Folders.count {
				return asFolder.Folders[index]
			}
			return asFolder.Variables[index - asFolder.Folders.count]
			
		default:
			return _story!.Folders[index]
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if _story == nil {
			return false
		}
		
		switch item {
		case is NVFolder:
			let asFolder = item as! NVFolder
			return (asFolder.Folders.count + asFolder.Variables.count) > 0
			
		case is NVVariable:
			return false
			
		default:
			return _story!.Folders.count > 0
		}
	}
}
