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
	@IBOutlet weak var currentNodeInfo: NSTextField!
	@IBOutlet weak var currNodeOutlineView: NSOutlineView!
	
	var _story: NVStory?
	var _simulator: NVSimulator?
	
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
		do {
			let (story, errors) = try NVStory.fromJSON(str: contents)
			_story = story
			
			for e in errors {
				print(e)
			}
			
			_story?.debugPrint(global: true)
		} catch {
			print("Failed to parse JSON.")
			return
		}
		
		
		// open the simulator
		_simulator = NVSimulator(story: _story!, controller: self)
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
		
		var text = "<b>UUID:</b><br/>\(node._uuid.uuidString)<br/><br/>"
		if let dialog = node as? NVDialog {
			text += "<b>Preview:</b><br/>\(dialog._preview.isEmpty ? "none" : dialog._preview)<br/><br/>"
			text += "<b>Content:</b><br/>\(dialog._content.isEmpty ? "none" : dialog._content)<br/><br/>"
			text += "<b>Directions:</b><br/>\(dialog._directions.isEmpty ? "none" : dialog._directions)"
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
		if _story == nil {
			return 0
		}
		
		if let folder = item as? NVFolder {
			return folder._folders.count + folder._variables.count
		}
		
		if let graph = item as? NVGraph {
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
		
		if let folder = item as? NVFolder {
			if index < folder._folders.count {
				return folder._folders[index]
			}
			return folder._variables[index - folder._folders.count]
		}
		
		if let graph = item as? NVGraph {
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
		if let _ = item as? NVVariable {
			return false
		}
		
		if let folder = item as? NVFolder {
			return (folder._folders.count + folder._variables.count) > 0
		}
		
		if let graph = item as? NVGraph {
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
		
		if let variable = item as? NVVariable {
			name = "Variable: " + variable._name
		}
		if let folder = item as? NVFolder {
			name = "Folder: " + folder._name
		}
		if let graph = item as? NVGraph {
			name = "Graph: " + graph._name
		}
		if let node = item as? NVNode {
			name = "Node: " + node._name
		}
		if let link = item as? NVBaseLink {
			name = "BaseLink: " + link._uuid.uuidString
		}
		if let listener = item as? NVListener {
			name = "Listener: " + listener._uuid.uuidString
		}
		if let exit = item as? NVExitNode {
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
			infoLabel.stringValue = ""
			return
		}
		let item = outlineView.item(atRow: outlineView.selectedRow)

		var text = "Unhandled!"

		if let variable = item as? NVVariable {
			text = "<b>VARIABLE</b><br/>"
			text += "<b>UUID: </b>\(variable._uuid.uuidString)</br>"
			text += "<b>Name: </b>\(variable._name)<br/>"
			text += "<b>Synopsis: </b>\(variable._synopsis)<br/>"
			text += "<b>Type: </b>\(variable._type.stringValue)<br/>"
			text += "<b>Value: </b>\(variable._value)<br/>"
			text += "<b>Initial Value: </b>\(variable._initialValue)<br/>"
			text += "<b>Constant: </b>\(variable._constant)<br/>"
			text += "<b>Folder: </b>\(variable._folder?._name ?? "none")<br/>"
		}
		if let folder = item as? NVFolder {
			text = "<b>FOLDER</b><br/>"
			text += "<b>UUID: </b>\(folder._uuid.uuidString)<br/>"
			text += "<b>Name: </b>\(folder._name)<br/>"
			text += "<b>Parent: </b>\(folder._parent?._name ?? "none")<br/>"
			text += "<b>Subfolders: </b>\(folder._folders.count)<br/>"
			text += "<b>Variables: </b>\(folder._variables.count)<br/>"
		}
		if let graph = item as? NVGraph {
			text = "<b>GRAPH</b><br/>"
			text += "<b>UUID: </b>\(graph._uuid.uuidString)<br/>"
			text += "<b>Name: </b>\(graph._name)<br/>"
			text += "<b>Subgraphs: </b>\(graph._graphs.count)<br/>"
			text += "<b>Nodes: </b>\(graph._nodes.count)<br/>"
			text += "<b>Links: </b>\(graph._links.count)<br/>"
			text += "<b>Listeners: </b>\(graph._listeners.count)<br/>"
			text += "<b>Exits: </b>\(graph._exits.count)<br/>"
			text += "<b>Entry: </b>\(graph._entry?.UUID.uuidString ?? "none")<br/>"
		}
		if let node = item as? NVNode {
			text = "<b>NODE</b><br/>"
			text += "<b>UUID: </b>\(node._uuid.uuidString)<br/>"
			text += "<b>Name: </b>\(node._name)<br/>"
			if let dlg = node as? NVDialog {
				text += "<b>Type: </b>Dialog<br/>"
				text += "<b>Preview: </b>\(dlg._preview)<br/>"
				text += "<b>Content: </b>\(dlg._content)<br/>"
				text += "<b>Directions: </b>\(dlg._directions)<br/>"
			}
		}
		if let link = item as? NVLink {
			text = "<b>LINK</b><br/>"
			text += "<b>UUID: </b>\(link._uuid.uuidString)<br/>"
			text += "<b>Origin: </b>\(link._origin?.UUID.uuidString ?? "none")<br/>"
			text += "<b>Destination: </b>\(link._transfer._destination?.UUID.uuidString ?? "none")<br/>"
		}
		if let branch = item as? NVBranch {
			text = "<b>BRANCH</b><br/>"
			text += "<b>UUID: </b>\(branch._uuid.uuidString)<br/>"
			text += "<b>Origin: </b>\(branch._origin?.UUID.uuidString ?? "none")<br/>"
			text += "<b>True Destination: </b>\(branch._trueTransfer._destination?.UUID.uuidString ?? "none")<br/>"
			text += "<b>False Destination: </b>\(branch._falseTransfer._destination?.UUID.uuidString ?? "none")<br/>"
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
		
		let origin = (item as! NVBaseLink)._origin
		var originName = "none"
		if let graph = origin as? NVGraph { originName = graph._name }
		if let node = origin as? NVNode {	originName = node._name }
		
		
		if let asLink = item as? NVLink {
			let dest = asLink._transfer._destination
			var destName = "none"
			if let graph = dest as? NVGraph { destName = graph._name }
			if let node = dest as? NVNode { destName = node._name }
			
			text = "Link (\(originName)->\(destName))"
		}
		if let asBranch = item as? NVBranch {
			let tDest = asBranch._trueTransfer._destination
			var tDestName = "none"
			if let graph = tDest as? NVGraph { tDestName = graph._name }
			if let node = tDest as? NVNode { tDestName = node._name }
			let fDest = asBranch._falseTransfer._destination
			var fDestName = "none"
			if let graph = fDest as? NVGraph { fDestName = graph._name }
			if let node = fDest as? NVNode { fDestName = node._name }
			
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
