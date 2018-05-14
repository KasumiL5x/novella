//
//  ViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

enum SaveAlertResult {
	case save
	case dontsave
	case cancel
}

class MainViewController: NSViewController {
	// MARK: - - Constants -
	fileprivate static let SCROLL_SIZE: CGFloat = 6000.0
	fileprivate static let MIN_ZOOM: CGFloat = 0.2
	fileprivate static let MAX_ZOOM: CGFloat = 4.0
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory = NVStory()
	fileprivate var _openedFile: URL?
	fileprivate var _browserTopLevel: [String] = [
		"Graphs",
		"Variables"
	]
	
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _tabView: NSTabView!
	@IBOutlet fileprivate weak var _storyName: NSTextField!
	@IBOutlet fileprivate weak var _storyBrowser: NSOutlineView!
	
	// MARK: - - Initialization -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_story = NVStory()
		
		_storyBrowser.delegate = self
		_storyBrowser.dataSource = self
		_storyBrowser.target = self
		_storyBrowser.doubleAction = #selector(MainViewController.onStoryBrowserDoubleClick)
	}
	
	// MARK: - - Functions called from window -
	func onNew() {
		let saveAlertResult = alertSave(message: "Save Before New?", info: "Making a new Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory() {
				return
			}
			break
		case .dontsave:
			break
		}
		createEmptyStory()
		
		// no longer has an open file
		_openedFile = nil
		// no name
		_storyName.stringValue = ""
		
		reloadBrowser()
	}

	func onOpen() {
		let saveAlertResult = alertSave(message: "Save Before Open?", info: "Opening a Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory() {
				return
			}
			break
		case .dontsave:
			break
		}
		
		// open file
		let ofd = NSOpenPanel()
		ofd.title = "Open Novella Story JSON."
		ofd.canChooseFiles = true
		ofd.canChooseDirectories = false
		ofd.allowsMultipleSelection = false
		ofd.allowedFileTypes = ["json"]
		if ofd.runModal() != .OK {
			return
		}
		
		// read file contents
		let contents: String
		do { contents = try String(contentsOf: ofd.url!) } catch {
			alertError(message: "Failed to open.", info: "The selected JSON file could not be read.")
			return
		}
		
		// load story object from json string
		do {
			let (story, errors) = try NVStory.fromJSON(str: contents)
			if errors.count > 0 {
				_ = errors.map({
					alertError(message: "JSON parse error.", info: $0)
				})
				return
			}
			_story = story
		} catch {
			alertError(message: "Failed to load Story.", info: "Failed to load the story.")
			return
		}
		
		// remove all existing tabs
		for curr in _tabView.tabViewItems.reversed() {
			_tabView.removeTabViewItem(curr)
		}
		
		// add a new graph tab for each subgraph of the story
		for curr in _story.Graphs {
			addNewTab(forGraph: curr)
		}
		
		// store file url for saving
		_openedFile = ofd.url!
		
		// story name
		_storyName.stringValue = _story.Name
		
		reloadBrowser()
	}
	
	func onSave() {
		_ = saveStory()
	}
	
	func onClose() {
		let saveAlertResult = alertSave(message: "Save Before Close?", info: "Closing the Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory() {
				return
			}
			break
		case .dontsave:
			break
		}
		
		createEmptyStory()
		
		// no longer has an open file
		_openedFile = nil
		
		// no name
		_storyName.stringValue = ""
		
		reloadBrowser()
	}
	
	// MARK: - - Alerts -
	fileprivate func alertError(message: String, info: String) {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = info
		alert.alertStyle = .critical
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
	fileprivate func alertSave(message: String, info: String) -> SaveAlertResult {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = info
		alert.alertStyle = .critical
		alert.addButton(withTitle: "Save")
		alert.addButton(withTitle: "Don't Save")
		alert.addButton(withTitle: "Cancel")
		switch alert.runModal() {
		case NSApplication.ModalResponse.alertFirstButtonReturn:
			return .save
		case NSApplication.ModalResponse.alertSecondButtonReturn:
			return .dontsave
		default:
			return .cancel
		}
	}
	
	// MARK: - - Story Helpers -
	fileprivate func saveStory() -> Bool {
		if _openedFile == nil {
			let sfd = NSSavePanel()
			sfd.title = "Save Novella Story JSON."
			sfd.canCreateDirectories = true
			sfd.allowedFileTypes = ["json"]
			sfd.allowsOtherFileTypes = false
			if sfd.runModal() != .OK {
				return false
			}
			_openedFile = sfd.url!
		}
		
		let saveURL: URL
		saveURL = _openedFile!
		
		// convert story to json
		let jsonString: String
		do { jsonString = try _story.toJSON() } catch {
			alertError(message: "Failed to save.", info: "Unable to convert Story to JSON.")
			_openedFile = nil
			return false
		}
		
		// write json string to file
		do { try jsonString.write(to: saveURL, atomically: true, encoding: .utf8) } catch {
			alertError(message: "Failed to save.", info: "Unable to write JSON to file.")
			_openedFile = nil
			return false
		}
		
		return true
	}
	fileprivate func createEmptyStory() {
		// remove all existing tabs
		for curr in _tabView.tabViewItems.reversed() {
			_tabView.removeTabViewItem(curr)
		}
		// create a new story
		_story = NVStory()
	}
	
	// MARK: - - TabView Functions -
	fileprivate func addNewTab(forGraph: NVGraph) {
		let tabViewItem = NSTabViewItem()
		tabViewItem.label = forGraph.Name
		let view = tabViewItem.view!
		
		let scrollView = NSScrollView()
		scrollView.allowsMagnification = true
		scrollView.minMagnification = MainViewController.MIN_ZOOM
		scrollView.maxMagnification = MainViewController.MAX_ZOOM
		scrollView.hasVerticalRuler = true
		scrollView.hasHorizontalRuler = true
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))
		
		let graphView = GraphView(graph: forGraph,story: _story, frameRect: NSMakeRect(0.0, 0.0, MainViewController.SCROLL_SIZE, MainViewController.SCROLL_SIZE))
		scrollView.documentView = graphView
		
		_tabView.addTabViewItem(tabViewItem)
	}
	
	fileprivate func getActiveGraph() -> GraphView? {
		// NOTE: This is fugly as hell but it is functional based on the setup I have.  If that changes, this will have to also.
		let graph = ((_tabView.selectedTabViewItem?.view?.subviews[0] as? NSScrollView)?.documentView as? GraphView)
		return graph
	}
	
	fileprivate func isGraphOpen(graph: NVGraph) -> Bool {
		return _tabView.tabViewItems.first(where: {
			(($0.view?.subviews[0] as? NSScrollView)?.documentView as? GraphView)?.NovellaGraph == graph
		}) != nil
	}
	
	// MARK: - - Interface Buttons -
	@IBAction func onCloseTab(_ sender: NSButton) {
		if let item = _tabView.selectedTabViewItem {
			_tabView.removeTabViewItem(item)
		}
	}
	
	@IBAction func onAddGraph(_ sender: NSButton) {
		let graph = _story.makeGraph(name: NSUUID().uuidString)
		do { try _story.add(graph: graph) } catch {
			alertError(message: "Could not add Graph!", info: "Adding a graph to the Story failed.")
			return // TODO: Remove graph
		}
		addNewTab(forGraph: graph)
	}
	
	@IBAction func onUndo(_ sender: NSButton) {
		getActiveGraph()?.undo()
	}
	
	@IBAction func onRedo(_ sender: NSButton) {
		getActiveGraph()?.redo()
	}
	
	// MARK: - - Story Browser Functions -
	func reloadBrowser() {
		_storyBrowser.reloadData()
	}
}

// MARK: - - Story Browser -
extension MainViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
	@objc fileprivate func onStoryBrowserDoubleClick() {
		let clickedRow = _storyBrowser.clickedRow
		if -1 == clickedRow {
			return
		}
		
		let clickedItem = _storyBrowser.item(atRow: clickedRow)
		
		if let asGraph = clickedItem as? NVGraph {
			if !isGraphOpen(graph: asGraph) {
				addNewTab(forGraph: asGraph)
			}
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let asFolder = item as? NVFolder {
			return asFolder.Folders.count + asFolder.Variables.count
		}
		
		if let asGraph = item as? NVGraph {
			return (asGraph.Graphs.count +
			        asGraph.Nodes.count +
							asGraph.Links.count)
		}
		
		if let asString = item as? String {
			if asString == _browserTopLevel[0] {
				return _story.Graphs.count
			}
			if asString == _browserTopLevel[1] {
				return _story.Folders.count
			}
		}
		
		return _browserTopLevel.count
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let asFolder = item as? NVFolder {
			if index < asFolder.Folders.count {
				return asFolder.Folders[index]
			}
			return asFolder.Variables[index - asFolder.Folders.count]
		}
		
		if let asGraph = item as? NVGraph {
			if index < asGraph.Graphs.count {
				return asGraph.Graphs[index]
			}
			var offset = asGraph.Graphs.count
			
			if index < (offset + asGraph.Nodes.count) {
				return asGraph.Nodes[index - offset]
			}
			offset += asGraph.Nodes.count
			
			if index < (offset + asGraph.Links.count) {
				return asGraph.Links[index - offset]
			}
			offset += asGraph.Links.count
			
			return "umm?"
		}
		
		if let asString = item as? String {
			if asString == _browserTopLevel[0] {
				return _story.Graphs[index]
			}
			if asString == _browserTopLevel[1] {
				return _story.Folders[index]
			}
		}
		
		return _browserTopLevel[index]
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let asFolder = item as? NVFolder {
			return (asFolder.Folders.count + asFolder.Variables.count) > 0
		}
		
		if let asGraph = item as? NVGraph {
			return (asGraph.Graphs.count +
				      asGraph.Nodes.count +
				      asGraph.Links.count) > 0
		}
		
		if let asString = item as? String {
			if asString == _browserTopLevel[0] {
				return _story.Graphs.count > 0
			}
			if asString == _browserTopLevel[1] {
				return _story.Folders.count > 0
			}
		}
		
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = "error"
		
		if item is String {
			name = item as! String
		}
		
		if let asFolder = item as? NVFolder {
			name = asFolder.Name
		}
		
		if let asVariable = item as? NVVariable {
			name = asVariable.Name
		}
		
		if let asGraph = item as? NVGraph {
			name = asGraph.Name
		}
		
		if let asDialog = item as? NVDialog {
			name = asDialog.Name
		}
		
		if let asLink = item as? NVLink {
			let from = _story.getNameOf(linkable: asLink.Origin)
			let to = _story.getNameOf(linkable: asLink.Transfer.Destination)
			name = "\(from) => \(to)"
		}
		
		if let asBranch = item as? NVBranch {
			let from = _story.getNameOf(linkable: asBranch.Origin)
			let toTrue = _story.getNameOf(linkable: asBranch.TrueTransfer.Destination)
			let toFalse = _story.getNameOf(linkable: asBranch.FalseTransfer.Destination)
			name = "\(from) => T=\(toTrue); F=\(toFalse)"
		}
		
		if tableColumn?.identifier.rawValue == "NameCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = name
		}
		
		return view
	}
}

