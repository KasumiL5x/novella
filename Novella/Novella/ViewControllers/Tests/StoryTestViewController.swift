//
//  StoryTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 15/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class StoryTestViewController: NSViewController {
	let _story: NVStory = NVStory()
	
//	@IBOutlet weak var browser: NSBrowser!
	@IBOutlet weak var outline: NSOutlineView!
	@IBOutlet weak var statusLabel: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// set up some story graph and variable content
//		let mainGraph = try! _story.add(graph: _story.makeGraph(name: "main"))
//		let mq1 = try! mainGraph.add(graph: _story.makeGraph(name: "quest1"))
//		try! mq1.add(graph: _story.makeGraph(name: "objective1"))
//		let mq2 = try! mainGraph.add(graph: _story.makeGraph(name: "quest2"))
//		try! mq2.add(graph: _story.makeGraph(name: "objective1"))
//		try! mq2.add(graph: _story.makeGraph(name: "objective2"))
//		let side = try! _story.add(graph: _story.makeGraph(name: "side"))
//		try! side.add(graph: _story.makeGraph(name: "quest1"))
//		try! side.add(graph: _story.makeGraph(name: "quest2"))
//		//
//		let mainFolder = try! _story.add(folder: _story.makeFolder(name: "story"))
//		let chars = try! mainFolder.add(folder: _story.makeFolder(name: "characters"))
//		let player = try! chars.add(folder: _story.makeFolder(name: "player"))
//		try! player.add(variable: _story.makeVariable(name: "health", type: .integer))
//		let decs = try! mainFolder.add(folder: _story.makeFolder(name: "choices"))
//		try! decs.add(variable: _story.makeVariable(name: "talked_to_dave", type: .boolean))
//		try! decs.add(variable: _story.makeVariable(name: "completed_task", type: .boolean))
//
//		outline.reloadData()
	}
	
	@IBAction func onAddRootgraph(_ sender: NSButton) {
//		let name = NSUUID().uuidString
//		do{ try _story.add(graph: _story.makeGraph(name: name)) } catch {
//			statusLabel.stringValue = "Could not add FG to Story as name was taken."
//		}
//		outline.reloadData()
	}
	
	@IBAction func onAddGraph(_ sender: NSButton) {
//		let idx = outline.selectedRow
//		if -1 == idx {
//			return
//		}
//		if let graph = outline.item(atRow: idx) as? NVGraph {
//			let name = NSUUID().uuidString
//			do{ try _story.add(graph: _story.makeGraph(name: name)) } catch {
//				statusLabel.stringValue = "Could not add FG to \(graph.Name) as name was taken."
//			}
//		}
//		outline.reloadData()
	}
	
	@IBAction func onRemoveGraph(_ sender: NSButton) {
		let idx = outline.selectedRow
		if -1 == idx {
			return
		}
		
		let item = outline.item(atRow: idx)
		if let graph = item as? NVGraph {
			if graph.Parent != nil {
				try! graph.Parent?.remove(graph: graph)
			} else {
				try! graph.Story.remove(graph: graph)
			}
		}
		
		outline.reloadData()
	}
	
	@IBAction func onPrintPath(_ sender: NSButton) {
		let idx = outline.selectedRow
		if -1 == idx {
			return
		}
		
		let item = outline.item(atRow: idx)
		
		if let path = item as? NVPathable {
			print(NVPath.fullPathTo(path))
		}
	}
}

extension StoryTestViewController: NSTextFieldDelegate {
	func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
		let item = outline.item(atRow: outline.selectedRow)
		if let _ = item as? NVVariable {
			return false
		}
		if let _ = item as? NVFolder {
			return false
		}
		return true
	}
	
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
		let item = outline.item(atRow: outline.selectedRow)
		
		if let graph = item as? NVGraph {
			graph.setName(fieldEditor.string)
		}
		
		return true
	}
}

extension StoryTestViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let _ = item as? NVVariable {
			return 0
		}
		
		if let folder = item as? NVFolder {
			return folder.Folders.count + folder.Variables.count
		}
		
		if let graph = item as? NVGraph {
			return graph.Graphs.count
		}
		
		return _story.Graphs.count + _story.Folders.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let folder = item as? NVFolder {
			if index < folder.Folders.count {
				return folder.Folders[index]
			}
			return folder.Variables[index - folder.Folders.count]
		}
		
		if let graph = item as? NVGraph {
			return graph.Graphs[index]
		}
		
		if index < _story.Graphs.count {
			return _story.Graphs[index]
		}
		return _story.Folders[index - _story.Graphs.count]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? NVVariable {
			return false
		}
		
		if let folder = item as? NVFolder {
			return (folder.Folders.count + folder.Variables.count) > 0
		}
		
		if let graph = item as? NVGraph {
			return graph.Graphs.count > 0
		}
		
		return (_story.Graphs.count + _story.Folders.count) > 0 // root folder
	}
}

extension StoryTestViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = ""
		var type = ""
		if let variable = item as? NVVariable {
			name = variable.Name
			type = "Variable"
		}
		if let folder = item as? NVFolder {
			name = folder.Name
			type = "Folder"
		}
		if let graph = item as? NVGraph {
			name = graph.Name
			type = "Graph"
		}
		
		if tableColumn?.identifier.rawValue == "NameCell" {
			view = outline.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = name
			}
		}
		if tableColumn?.identifier.rawValue == "TypeCell" {
			view = outline.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = type
			}
		}
		
		return view
	}
}
