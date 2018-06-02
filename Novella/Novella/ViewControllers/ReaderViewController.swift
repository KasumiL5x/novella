//
//  ReaderViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class ReaderViewController: NSViewController {
	// MARK: Storyboard references
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var infoLabel: NSTextField!
	@IBOutlet weak var currentNodeInfo: NSTextField!
	@IBOutlet weak var currNodeOutlineView: NSOutlineView!
	
	var _simulator: NVSimulator?
	var _manager: NVStoryManager?
	
	var _currNodeLinksCallback = CurrentNodeLinksCallbacks()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_currNodeLinksCallback.setView(view: currNodeOutlineView)
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		// https://stackoverflow.com/questions/42342231/how-to-show-touch-bar-in-a-viewcontroller
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
		self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
	}
	deinit {
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
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
		_manager = NVStoryManager.fromJSON(str: contents)
		if _manager == nil {
			print("Failed to parse JSON.")
			return
		}
		
		
		// open the simulator
		_simulator = NVSimulator(manager: _manager!, controller: self)
		outlineView.reloadData()
	}
	
	@IBAction func onSimulate(_ sender: NSButton) {
		if outlineView.selectedRow == -1 {
			return
		}
		let item = outlineView.item(atRow: outlineView.selectedRow)
		guard let graph = item as? NVGraph else {
			print("Please select a Graph.")
			return
		}
		
		if !_simulator!.start(graph) {
			print("Graph is not configured for simulation.")
			return
		}
		print("Simulation started...")
	}
	
	@IBAction func onFollowSelected(_ sender: NSButton) {
		if currNodeOutlineView.selectedRow == -1 {
			return
		}
		let link = currNodeOutlineView.item(atRow: currNodeOutlineView.selectedRow) as! NVBaseLink
		do {
			try _simulator?.proceed(link)
		} catch {
			print("Failed to proceed in Simulator.")
		}
	}
}

extension ReaderViewController: NVSimulatorController {
	func currentNode(node: NVNode, outputs: [NVBaseLink]) {
		_currNodeLinksCallback.setLinks(links: outputs)
		currNodeOutlineView.reloadData()
		
		var text = "<b>UUID:</b><br/>\(node.UUID.uuidString)<br/><br/>"
		if let dialog = node as? NVDialog {
			text += "<b>Preview:</b><br/>\(dialog.Preview.isEmpty ? "none" : dialog.Preview)<br/><br/>"
			text += "<b>Content:</b><br/>\(dialog.Content.isEmpty ? "none" : dialog.Content)<br/><br/>"
			text += "<b>Directions:</b><br/>\(dialog.Directions.isEmpty ? "none" : dialog.Directions)"
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
		currentNodeInfo.attributedStringValue = attrString
	}
}

extension ReaderViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let folder = item as? NVFolder {
			return folder.Folders.count + folder.Variables.count
		}
		
		if let graph = item as? NVGraph {
			return (
				graph.Graphs.count +
					graph.Nodes.count +
					graph.Links.count +
					graph.Listeners.count +
					graph.Exits.count
					+ 1 // entry
				)
		}
		
		return _manager!.Story.Folders.count + _manager!.Story.Graphs.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let folder = item as? NVFolder {
			if index < folder.Folders.count {
				return folder.Folders[index]
			}
			return folder.Variables[index - folder.Folders.count]
		}
		
		if let graph = item as? NVGraph {
			if index < graph.Graphs.count { return graph.Graphs[index] }
			var offset = graph.Graphs.count
			
			if index < offset + graph.Nodes.count { return graph.Nodes[index - offset] }
			offset += graph.Nodes.count
			
			if index < offset + graph.Links.count { return graph.Links[index - offset] }
			offset += graph.Links.count
			
			if index < offset + graph.Listeners.count { return graph.Listeners[index - offset] }
			offset += graph.Listeners.count
			
			if index < offset + graph.Exits.count { return graph.Exits[index - offset] }
			offset += graph.Exits.count
			
			return graph.Entry
		}
		
		if index < _manager!.Story.Graphs.count {
			return _manager!.Story.Graphs[index]
		}
		return _manager!.Story.Folders[index - _manager!.Story.Graphs.count]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? NVVariable {
			return false
		}
		
		if let folder = item as? NVFolder {
			return (folder.Folders.count + folder.Variables.count) > 0
		}
		
		if let graph = item as? NVGraph {
			return (
				graph.Graphs.count +
				graph.Nodes.count +
				graph.Links.count +
				graph.Listeners.count +
				graph.Exits.count
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
		
		if let variable = item as? NVVariable {
			name = "Variable: " + variable.Name
		}
		if let folder = item as? NVFolder {
			name = "Folder: " + folder.Name
		}
		if let graph = item as? NVGraph {
			name = "Graph: " + graph.Name
		}
		if let node = item as? NVNode {
			name = "Node: " + node.Name
		}
		if let link = item as? NVBaseLink {
			name = "BaseLink: " + link.UUID.uuidString
		}
		if let listener = item as? NVListener {
			name = "Listener: " + listener.UUID.uuidString
		}
		if let exit = item as? NVExitNode {
			name = "ExitNode: " + exit.UUID.uuidString
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
			infoLabel.stringValue = ""
			return
		}
		let item = outlineView.item(atRow: outlineView.selectedRow)

		var text = "Unhandled!"

		if let variable = item as? NVVariable {
			text = "<b>VARIABLE</b><br/>"
			text += "<b>UUID: </b>\(variable.UUID.uuidString)</br>"
			text += "<b>Name: </b>\(variable.Name)<br/>"
			text += "<b>Synopsis: </b>\(variable.Synopsis)<br/>"
			text += "<b>Type: </b>\(variable.DataType.stringValue)<br/>"
			text += "<b>Value: </b>\(variable.Value)<br/>"
			text += "<b>Initial Value: </b>\(variable.InitialValue)<br/>"
			text += "<b>Constant: </b>\(variable.IsConstant)<br/>"
			text += "<b>Folder: </b>\(variable.Folder?.Name ?? "none")<br/>"
		}
		if let folder = item as? NVFolder {
			text = "<b>FOLDER</b><br/>"
			text += "<b>UUID: </b>\(folder.UUID.uuidString)<br/>"
			text += "<b>Name: </b>\(folder.Name)<br/>"
			text += "<b>Parent: </b>\(folder.Parent?.Name ?? "none")<br/>"
			text += "<b>Subfolders: </b>\(folder.Folders.count)<br/>"
			text += "<b>Variables: </b>\(folder.Variables.count)<br/>"
		}
		if let graph = item as? NVGraph {
			text = "<b>GRAPH</b><br/>"
			text += "<b>UUID: </b>\(graph.UUID.uuidString)<br/>"
			text += "<b>Name: </b>\(graph.Name)<br/>"
			text += "<b>Subgraphs: </b>\(graph.Graphs.count)<br/>"
			text += "<b>Nodes: </b>\(graph.Nodes.count)<br/>"
			text += "<b>Links: </b>\(graph.Links.count)<br/>"
			text += "<b>Listeners: </b>\(graph.Listeners.count)<br/>"
			text += "<b>Exits: </b>\(graph.Exits.count)<br/>"
			text += "<b>Entry: </b>\(graph.Entry?.UUID.uuidString ?? "none")<br/>"
		}
		if let node = item as? NVNode {
			text = "<b>NODE</b><br/>"
			text += "<b>UUID: </b>\(node.UUID.uuidString)<br/>"
			text += "<b>Name: </b>\(node.Name)<br/>"
			if let dlg = node as? NVDialog {
				text += "<b>Type: </b>Dialog<br/>"
				text += "<b>Preview: </b>\(dlg.Preview)<br/>"
				text += "<b>Content: </b>\(dlg.Content)<br/>"
				text += "<b>Directions: </b>\(dlg.Directions)<br/>"
			}
		}
		if let link = item as? NVLink {
			text = "<b>LINK</b><br/>"
			text += "<b>UUID: </b>\(link.UUID.uuidString)<br/>"
			text += "<b>Origin: </b>\(link.Origin.UUID.uuidString)<br/>"
			text += "<b>Destination: </b>\(link.Transfer.Destination?.UUID.uuidString ?? "none")<br/>"
		}
		if let branch = item as? NVBranch {
			text = "<b>BRANCH</b><br/>"
			text += "<b>UUID: </b>\(branch.UUID.uuidString)<br/>"
			text += "<b>Origin: </b>\(branch.Origin.UUID.uuidString)<br/>"
			text += "<b>True Destination: </b>\(branch.TrueTransfer.Destination?.UUID.uuidString ?? "none")<br/>"
			text += "<b>False Destination: </b>\(branch.FalseTransfer.Destination?.UUID.uuidString ?? "none")<br/>"
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

// MARK: currentNodeList callbacks
class CurrentNodeLinksCallbacks: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
	var _view: NSOutlineView?
	var _links: [NVBaseLink] = []
	
	override init() {
	}
	
	func setView(view: NSOutlineView) {
		_view = view
		_view!.delegate = self
		_view!.dataSource = self
	}
	
	func setLinks(links: [NVBaseLink]) {
		self._links = links
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		return _links.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return _links[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var text = "error"
		
		let origin = (item as! NVBaseLink).Origin
		var originName = "none"
		if let graph = origin as? NVGraph { originName = graph.Name }
		if let node = origin as? NVNode {	originName = node.Name }
		
		
		if let asLink = item as? NVLink {
			let dest = asLink.Transfer.Destination
			var destName = "none"
			if let graph = dest as? NVGraph { destName = graph.Name }
			if let node = dest as? NVNode { destName = node.Name }
			
			text = "Link (\(originName)->\(destName))"
		}
		if let asBranch = item as? NVBranch {
			let tDest = asBranch.TrueTransfer.Destination
			var tDestName = "none"
			if let graph = tDest as? NVGraph { tDestName = graph.Name }
			if let node = tDest as? NVNode { tDestName = node.Name }
			let fDest = asBranch.FalseTransfer.Destination
			var fDestName = "none"
			if let graph = fDest as? NVGraph { fDestName = graph.Name }
			if let node = fDest as? NVNode { fDestName = node.Name }
			
			text = "Branch (\(originName)->T(\(tDestName)); F(\(fDestName)))"
		}
		if let _ = item as? NVSwitch {
			text = "Switch"
		}
		
		if tableColumn?.identifier.rawValue == "LinkCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LinkCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = text
			}
		}
		return view
	}
}
