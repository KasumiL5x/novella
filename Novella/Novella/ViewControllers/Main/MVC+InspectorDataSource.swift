//
//  MVC+InspectorDataSource.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

typealias NamedValue = (key: String, value: Any)

class InspectorDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	var _target: Any?
	
	var _dialogDict: [NamedValue] = []
	var _graphDict: [NamedValue] = []
	
	override init() {
		super.init()
		nilAllTargets()
	}
	
	fileprivate func nilAllTargets() {
		_target = nil
		_dialogDict = []
		_graphDict = []
	}
	
	func refresh() {
		// just set target back to itself which will reparse everything
		if _target != nil {
			setTarget(target: _target)
		}
	}
	
	func setTarget(target: Any?) {
		nilAllTargets()
		
		if nil == target {
			return
		}
		
		switch target {
		case is NVDialog:
			let dialog = target as! NVDialog
			_dialogDict = [
				("Name", dialog.Name),
				("Preview", dialog.Preview),
				("Content", dialog.Content),
				("Directions", dialog.Directions),
				("Position", "(\(dialog.EditorPosition.x), \(dialog.EditorPosition.y))")
			]
			
		case is NVGraph:
			let graph = target as! NVGraph
			_graphDict = [
				("Name", graph.Name),
				("Position", "(\(graph.EditorPosition.x), \(graph.EditorPosition.y))"),
				("Subgraphs", "\(graph.Graphs.count)"),
				("Nodes", "\(graph.Nodes.count)"),
				("Links", "\(graph.Links.count)")
			]
		default:
			print("Given target was not handled in the switch (\(target!)).")
			return
		}
		
		_target = target
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		switch _target {
		case is NVDialog:
			return _dialogDict.count
		case is NVGraph:
			return _graphDict.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSTableCellView?
		
		if tableColumn?.identifier.rawValue == "NameColumn" {
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameDataCell"), owner: self) as? NSTableCellView
			
			switch _target {
			case is NVDialog:
				view?.textField?.stringValue = _dialogDict[row].key
			case is NVGraph:
				view?.textField?.stringValue = _graphDict[row].key
			default:
				view?.textField?.stringValue = "ERROR"
			}
		}
		
		if tableColumn?.identifier.rawValue == "ValueColumn" {
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ValueDataCell"), owner: self) as? NSTableCellView
			
			switch _target {
			case is NVDialog:
				view?.textField?.stringValue = _dialogDict[row].value as! String
			case is NVGraph:
				view?.textField?.stringValue = _graphDict[row].value as! String
			default:
				view?.textField?.stringValue = "ERROR"
			}
		}
		
		return view
	}
}
