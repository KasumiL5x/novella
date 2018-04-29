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
	@IBOutlet weak var infoLabel: NSTextField!
	
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
		
		if let folder = item as? Folder {
			return folder._folders.count + folder._variables.count
		}
		
		if let graph = item as? FlowGraph {
			return (
				graph._graphs.count +
					graph._nodes.count +
					graph._links.count +
					graph._listeners.count +
					graph._exits.count
					+ 1 // entry
				)
		}
		
		return _story!._folders.count + _story!._graphs.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if _story == nil {
			return ""
		}
		
		if let folder = item as? Folder {
			if index < folder._folders.count {
				return folder._folders[index]
			}
			return folder._variables[index - folder._folders.count]
		}
		
		if let graph = item as? FlowGraph {
			if index < graph._graphs.count { return graph._graphs[index] }
			var offset = graph._graphs.count
			
			if index < offset + graph._nodes.count { return graph._nodes[index - offset] }
			offset += graph._nodes.count
			
			if index < offset + graph._links.count { return graph._links[index - offset] }
			offset += graph._links.count
			
			if index < offset + graph._listeners.count { return graph._listeners[index - offset] }
			offset += graph._listeners.count
			
			if index < offset + graph._exits.count { return graph._exits[index - offset] }
			offset += graph._exits.count
			
			return graph._entry
		}
		
		if index < _story!._graphs.count {
			return _story!._graphs[index]
		}
		return _story!._folders[index - _story!._graphs.count]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? Variable {
			return false
		}
		
		if let folder = item as? Folder {
			return (folder._folders.count + folder._variables.count) > 0
		}
		
		if let graph = item as? FlowGraph {
			return (
				graph._graphs.count +
				graph._nodes.count +
				graph._links.count +
				graph._listeners.count +
				graph._exits.count
				+ 1 // entry
			) > 0
		}
		
		return false
	}
}
extension ReaderViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = "ERROR"
		
		if let variable = item as? Variable {
			name = "Variable: " + variable._name
		}
		if let folder = item as? Folder {
			name = "Folder: " + folder._name
		}
		if let graph = item as? FlowGraph {
			name = "FlowGraph: " + graph._name
		}
		if let node = item as? FlowNode {
			name = "FlowNode: " + node._uuid.uuidString
		}
		if let link = item as? BaseLink {
			name = "BaseLink: " + link._uuid.uuidString
		}
		if let listener = item as? Listener {
			name = "Listener: " + listener._uuid.uuidString
		}
		if let exit = item as? ExitNode {
			name = "ExitNode: " + exit._uuid.uuidString
		}
		
		if tableColumn?.identifier.rawValue == "StoryCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "StoryCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = name
			}
		}
		
		return view
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		if outlineView.selectedRow == -1 {
			return
		}
		let item = outlineView.item(atRow: outlineView.selectedRow)

		var text = "Unhandled!"

		if let variable = item as? Variable {
			text = "A <b>variable</b> named \(variable._name) storing a \(variable._type.stringValue)."
		}
		if let folder = item as? Folder {
			text = "A <b>folder</b> named \(folder._name) with \(folder._folders.count) subfolders and \(folder._variables.count) variables."
		}
		if let graph = item as? FlowGraph {
			text = "A <b>graph</b> named \(graph._name)."
		}

		let html = "<html><head><style>*{font-family: Arial, Helvetica, sans-serif; font-size: 10pt;}</style></head><body>\n" + text + "\n</body></html>"
		guard let data = html.data(using: .utf8, allowLossyConversion: false) else {
			print("Couldn't get text data.")
			return
		}
		guard let attrString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
			print("Could not initialize attributed string.")
			return
		}
		infoLabel.attributedStringValue = attrString
	}
}
