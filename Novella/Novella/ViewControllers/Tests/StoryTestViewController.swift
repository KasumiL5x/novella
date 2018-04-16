//
//  StoryTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 15/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class StoryTestViewController: NSViewController {
	var _story: Story = Story()
	
//	@IBOutlet weak var browser: NSBrowser!
	@IBOutlet weak var outline: NSOutlineView!
	@IBOutlet weak var statusLabel: NSTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up some story graph and variable content
		let mq1 = try! _story.MainGraph.makeGraph(name: "quest1")
			let _ = try! mq1.makeGraph(name: "objective1")
		let mq2 = try! _story.MainGraph.makeGraph(name: "quest2")
			let _ = try! mq2.makeGraph(name: "objective1")
			let _ = try! mq2.makeGraph(name: "objective2")
		//
		let side = try! _story.makeGraph(name: "side")
		let _ = try! side.makeGraph(name: "quest1")
		let _ = try! side.makeGraph(name: "quest2")
		//
		let chars = try! _story.MainFolder.mkdir(name: "characters")
			let player = try! chars.mkdir(name: "player")
				let _ = try! player.mkvar(name: "health", type: .integer)
		let decs = try! _story.MainFolder.mkdir(name: "choices")
			let _ = try! decs.mkvar(name: "talked_to_dave", type: .boolean)
			let _ = try! decs.mkvar(name: "completed_task", type: .boolean)
		
		outline.reloadData()
	}
	
	@IBAction func onAddRootgraph(_ sender: NSButton) {
		let name = NSUUID().uuidString
		do{ let _ = try _story.makeGraph(name: name) } catch {
			statusLabel.stringValue = "Could not add FG to Story as name was taken."
		}
		outline.reloadData()
	}
	
	@IBAction func onAddGraph(_ sender: NSButton) {
		let idx = outline.selectedRow
		if -1 == idx {
			return
		}
		if let graph = outline.item(atRow: idx) as? FlowGraph {
			let name = NSUUID().uuidString
			do{ let _ = try graph.makeGraph(name: name) } catch {
				statusLabel.stringValue = "Could not add FG to \(graph.Name) as name was taken."
			}
		}
		outline.reloadData()
	}
	
	@IBAction func onRemoveGraph(_ sender: NSButton) {
		let idx = outline.selectedRow
		if -1 == idx {
			return
		}
		
		let item = outline.item(atRow: idx)
		if let graph = item as? FlowGraph {
			if graph._parent != nil {
				try! graph._parent?.remove(graph: graph)
			} else {
				try! graph._story?.remove(graph: graph)
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
		
		if let path = item as? Pathable {
			print(Path.fullPathTo(object: path))
		}
	}
}

extension StoryTestViewController: NSTextFieldDelegate {
	func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
		let item = outline.item(atRow: outline.selectedRow)
		if let _ = item as? Variable {
			return false
		}
		if let _ = item as? Folder {
			return false
		}
		return true
	}
	
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
		let item = outline.item(atRow: outline.selectedRow)
		
		if let graph = item as? FlowGraph {
			do{ try graph.setName(name: fieldEditor.string) } catch {
				statusLabel.stringValue = "Could not rename FG (\(graph.Name)->\(fieldEditor.string))!"
			}
		}
		
		return true
	}
}

extension StoryTestViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let _ = item as? Variable {
			return 0
		}
		
		if let folder = item as? Folder {
			return folder._folders.count + folder._variables.count
		}
		
		if let graph = item as? FlowGraph {
			return graph._graphs.count
		}
		
		return _story._graphs.count + 1 // root folder
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let folder = item as? Folder {
			if index < folder._folders.count {
				return folder._folders[index]
			}
			return folder._variables[index - folder._folders.count]
		}
		
		if let graph = item as? FlowGraph {
			return graph._graphs[index]
		}
		
		if index < _story._graphs.count {
			return _story._graphs[index]
		}
		return _story._mainFolder
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? Variable {
			return false
		}
		
		if let folder = item as? Folder {
			return (folder._folders.count + folder._variables.count) > 0
		}
		
		if let graph = item as? FlowGraph {
			return graph._graphs.count > 0
		}
		
		return (_story._graphs.count + 1) > 0 // root folder
	}
}

extension StoryTestViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = ""
		var type = ""
		if let variable = item as? Variable {
			name = variable.Name
			type = "Variable"
		}
		if let folder = item as? Folder {
			name = folder.Name
			type = "Folder"
		}
		if let graph = item as? FlowGraph {
			name = graph._name
			type = "FlowGraph"
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
