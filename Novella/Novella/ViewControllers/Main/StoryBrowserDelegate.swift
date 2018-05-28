//
//  MVC+StoryBrowserDelegate.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class StoryBrowserDelegate: NSObject, NSOutlineViewDelegate {
	fileprivate let _mvc: MainViewController
	fileprivate var _graphIcon: NSImage?
	fileprivate var _folderIcon: NSImage?
	fileprivate var _variableIcon: NSImage?
	fileprivate var _dialogIcon: NSImage?
	
	init(mvc: MainViewController) {
		self._mvc = mvc
		
		// load icons
		_graphIcon = NSImage(named: NSImage.Name(rawValue: "Graph"))
		_folderIcon = NSImage(named: NSImage.Name(rawValue: "Folder"))
		_variableIcon = NSImage(named: NSImage.Name(rawValue: "Variable"))
		_dialogIcon = NSImage(named: NSImage.Name(rawValue: "Dialog"))
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if item is String {
			return true
		}
		return false
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		guard let outlineView = notification.object as? NSOutlineView else {
			print("Expected an NSOutlineView but didn't receive one.")
			return
		}
		
		let idx = outlineView.selectedRow
		if idx == -1 {
			return
		}
		
		let item = outlineView.item(atRow: idx)
		
		if item is NVDialog || item is NVDelivery || item is NVGraph || item is NVContext {
			_mvc.InspectorDelegate?.setTarget(target: item)
			_mvc.reloadInspector()
		} else {
			_mvc.InspectorDelegate?.setTarget(target: nil)
			_mvc.reloadInspector()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		if let asString = item as? String {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = asString
		} else {
			var name = "error"
			var icon: NSImage? = nil
			switch item {
			case is NVFolder:
				name = (item as! NVFolder).Name
				icon = _folderIcon
				
			case is NVVariable:
				name = (item as! NVVariable).Name
				icon = _variableIcon
				
			case is NVGraph:
				name = (item as! NVGraph).Name
				icon = _graphIcon
				
			case is NVDialog:
				name = (item as! NVDialog).Name
				icon = _dialogIcon
				
			case is NVDelivery:
				name = (item as! NVDelivery).Name
				icon = _dialogIcon
				
			case is NVContext:
				name = (item as! NVContext).Name
				
			case is NVLink:
				let from = _mvc.StoryManager.nameOf(linkable: (item as! NVLink).Origin)
				let to = _mvc.StoryManager.nameOf(linkable: (item as! NVLink).Transfer.Destination)
				name = "\(from) => \(to)"
				icon = nil
				
			case is NVBranch:
				let from = _mvc.StoryManager.nameOf(linkable: (item as! NVBranch).Origin)
				let toTrue = _mvc.StoryManager.nameOf(linkable: (item as! NVBranch).TrueTransfer.Destination)
				let toFalse = _mvc.StoryManager.nameOf(linkable: (item as! NVBranch).FalseTransfer.Destination)
				name = "\(from) => T=\(toTrue); F=\(toFalse)"
				icon = nil
				
			default:
				break
			}
			
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = name
			view?.imageView?.image = icon
		}
		
		return view
	}
}
