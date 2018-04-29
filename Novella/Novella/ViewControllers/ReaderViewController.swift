//
//  ReaderViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ReaderViewController: NSViewController {
	// MARK: Storyboard references
	@IBOutlet weak var outlineView: NSOutlineView!
	
	var _story: Story?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func onOpen(_ sender: NSButton) {
		// open file
		let ofd = NSOpenPanel()
		ofd.title = "Select Novella JSON."
		ofd.canChooseDirectories = false
		ofd.canChooseFiles = true
		ofd.allowsMultipleSelection = false
		ofd.allowedFileTypes = ["json"]
		if ofd.runModal() != NSApplication.ModalResponse.OK {
			print("User cancelled open.")
			return
		}
		
		// read file contents
		let contents: String
		do {
			contents = try String(contentsOf: ofd.url!)
		}
		catch {
			print("Failed to read file.")
			return
		}
		
		// parse contents into a Story
		do {
			_story = try Story.fromJSON(str: contents)
		} catch {
			print("Failed to parse JSON.")
			return
		}
		
		_story?.debugPrint(global: true)
		
		outlineView.reloadData()
	}
}

extension ReaderViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if _story == nil {
			return 0
		}
		
		return _story!._folders.count + _story!._graphs.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if _story == nil {
			return ""
		}
		
		if index < _story!._graphs.count {
			return _story!._graphs[index]
		}
		return _story!._folders[index - _story!._graphs.count]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
}
extension ReaderViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = "ERROR"
		
		if let folder = item as? Folder {
			name = folder._name + " (Folder)"
		}
		if let graph = item as? FlowGraph {
			name = graph._name + " (Graph)"
		}
		
		if tableColumn?.identifier.rawValue == "StoryCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StoryCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = name
			}
		}
		
		return view
	}
}
