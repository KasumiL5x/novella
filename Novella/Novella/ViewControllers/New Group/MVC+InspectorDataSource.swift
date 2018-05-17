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
	
	func clearTarget() {
		nilAllTargets()
	}
	
	func setTarget(dialog: NVDialog) {
		nilAllTargets()
		_target = dialog
		
		_dialogDict = [
			("Name", dialog.Name),
			("Preview", dialog.Preview),
			("Content", dialog.Content),
			("Directions", dialog.Directions),
			("Position", "(\(dialog.EditorPosition.x), \(dialog.EditorPosition.y))")
		]
	}
	
	func setTarget(graph: NVGraph) {
		nilAllTargets()
		_target = graph
		
		_graphDict = [
			("Name", graph.Name),
			("Position", "(\(graph.EditorPosition.x), \(graph.EditorPosition.y))"),
			("Subgraphs", "\(graph.Graphs.count)"),
			("Nodes", "\(graph.Nodes.count)"),
			("Links", "\(graph.Links.count)")
		]
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
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
			
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
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
			
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
