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
		
		let _ = try! _story.makeGraph(name: "side")
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
		if let graph = item as? FlowGraph {
			print(Path.fullPathTo(object: graph))
		}
	}
	
	@IBAction func onNameEdited(_ sender: NSTextField) {
		let idx = outline.selectedRow
		if -1 == idx {
			return
		}

		let newName = sender.stringValue
		let item = outline.item(atRow: idx)
		if let graph = item as? FlowGraph {
			if newName == graph.Name {
				return
			}
			do { try graph.setName(name: newName) } catch {
				statusLabel.stringValue = "Could not rename FG (\(graph.Name)->\(newName))!"
				sender.stringValue = graph.Name
			}
		}
	}
	
}

extension StoryTestViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let graph = item as? FlowGraph {
			return graph._graphs.count
		}
		return _story._graphs.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let graph = item as? FlowGraph {
			return graph._graphs[index]
		}
		return _story._graphs[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let graph = item as? FlowGraph {
			return graph._graphs.count > 0
		}
		return _story._graphs.count > 0
	}
}

extension StoryTestViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = ""
		var type = ""
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
