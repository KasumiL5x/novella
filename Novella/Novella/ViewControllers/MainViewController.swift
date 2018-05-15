//
//  ViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel
import class KPCTabsControl.TabsControl
import struct KPCTabsControl.DefaultStyle
import struct KPCTabsControl.SafariStyle
import struct KPCTabsControl.ChromeStyle
import protocol KPCTabsControl.TabsControlDelegate
import protocol KPCTabsControl.TabsControlDataSource

enum SaveAlertResult {
	case save
	case dontsave
	case cancel
}

class TabItem {
	var title: String = ""
	var icon: NSImage?
	var menu: NSMenu?
	var altIcon: NSImage?
	var selectable: Bool
	var tabItem: NSTabViewItem
	
	init(title: String, icon: NSImage?, menu: NSMenu?, altIcon: NSImage?, tabItem: NSTabViewItem, selectable: Bool = true) {
		self.title = title
		self.icon = icon
		self.menu = menu
		self.altIcon = altIcon
		self.tabItem = tabItem
		self.selectable = selectable
	}
}
extension TabItem: Equatable {
	static func == (lhs: TabItem, rhs: TabItem) -> Bool {
		return lhs.title == rhs.title
	}
}

class MainViewController: NSViewController {
	// MARK: - - Constants -
	fileprivate static let SCROLL_SIZE: CGFloat = 6000.0
	fileprivate static let MIN_ZOOM: CGFloat = 0.2
	fileprivate static let MAX_ZOOM: CGFloat = 4.0
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory = NVStory()
	fileprivate var _openedFile: URL?
	fileprivate var _tabs: [TabItem] = []
	fileprivate var _selectedTab: TabItem?
	fileprivate var _browserTopLevel: [String] = [
		"Graphs",
		"Variables"
	]
	
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _tabView: NSTabView!
	@IBOutlet fileprivate weak var _storyName: NSTextField!
	@IBOutlet fileprivate weak var _storyBrowser: NSOutlineView!
	@IBOutlet weak var _tabController: TabsControl!
	
	// MARK: - - Images for Story Browser -
	fileprivate var _graphIcon: NSImage?
	fileprivate var _folderIcon: NSImage?
	fileprivate var _variableIcon: NSImage?
	fileprivate var _dialogIcon: NSImage?
	
	// MARK: - - Initialization -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// load icons
		_graphIcon = NSImage(named: NSImage.Name(rawValue: "Graph"))
		_folderIcon = NSImage(named: NSImage.Name(rawValue: "Folder"))
		_variableIcon = NSImage(named: NSImage.Name(rawValue: "Variable"))
		_dialogIcon = NSImage(named: NSImage.Name(rawValue: "Dialog"))
		
		_story = NVStory()
		_story.Delegate = self
		
		_storyBrowser.delegate = self
		_storyBrowser.dataSource = self
		_storyBrowser.target = self
		_storyBrowser.doubleAction = #selector(MainViewController.onStoryBrowserDoubleClick)
		
		_tabs = []
		_selectedTab = nil
		_tabController.style = ChromeStyle()
		_tabController.delegate = self
		_tabController.dataSource = self
		_tabController.reloadTabs()
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
		
		// close any current tabs
		closeAllTabs()
		
		// add a new graph tab for each subgraph of the story
		for curr in _story.Graphs {
			addNewTab(forGraph: curr)
		}
		// select first tab
		if _tabs.count > 0 {
			_tabController.reloadTabs()
			selectTab(item: _tabs[0])
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
		// close existing tabs
		closeAllTabs()
		// create a new story
		_story = NVStory()
	}
	
	// MARK: - - Tabs/TabView Functions -
	@discardableResult
	fileprivate func addNewTab(forGraph: NVGraph) -> TabItem {
		// make main tab view
		let tabViewItem = NSTabViewItem()
		tabViewItem.label = forGraph.Name
		let view = tabViewItem.view!
		
		// add and configure scroll view
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
		
		// create graph view and add it as the scroll view's document view
		let graphView = GraphView(graph: forGraph,story: _story, frameRect: NSMakeRect(0.0, 0.0, MainViewController.SCROLL_SIZE, MainViewController.SCROLL_SIZE), visibleRect: NSMakeRect(0.0, 0.0, _tabView.frame.size.width, _tabView.frame.size.height))
		graphView.Delegate = self
		scrollView.documentView = graphView
		
		// add to tab view
		_tabView.addTabViewItem(tabViewItem)
		
		// add to the tab control list
		let tabItem = TabItem(title: forGraph.Name, icon: nil, menu: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		_tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	fileprivate func closeTab(tab: TabItem) {
		guard let index = _tabs.index(of: tab) else { return }
		
		// re-assign selected tab if this tab was selected
		if _selectedTab == tab {
			// behavior of KPCTabsControl seems to be select to right if it exists, but don't select left and instead give nil
			_selectedTab = (index+1 >= _tabs.count) ? nil : _tabs[index+1]
		}
		
		// remove from tabs array
		_tabs.remove(at: index)
		
		// refresh tab control
		_tabController.reloadTabs()
		
		// remove from actual tab view
		_tabView.removeTabViewItem(tab.tabItem)
	}
	
	fileprivate func closeAllTabs() {
		_tabs = []
		_selectedTab = nil
		_tabController.reloadTabs()
		
		for curr in _tabView.tabViewItems.reversed() {
			_tabView.removeTabViewItem(curr)
		}
	}
	
	fileprivate func getGraphViewFromTab(tab: NSTabViewItem) -> GraphView? {
		// must have a view
		guard let view = tab.view else {
			return nil
		}
		// must have a subview
		if view.subviews.count < 1 {
			return nil
		}
		// subview must be a scrollview
		guard let scroll = view.subviews[0] as? NSScrollView else {
			return nil
		}
		return scroll.documentView as? GraphView
	}
	
	fileprivate func getActiveGraph() -> GraphView? {
		if let selectedTab = _selectedTab {
			return getGraphViewFromTab(tab: selectedTab.tabItem)
		}
		return nil
	}
	
	fileprivate func getTabForGraph(graph: NVGraph) -> NSTabViewItem? {
		return _tabs.first(where: {
			guard let graphView = getGraphViewFromTab(tab: $0.tabItem) else {
				return false
			}
			return graphView.NovellaGraph == graph
		})?.tabItem
	}
	
	// MARK: - - Interface Buttons -
	@IBAction func onCloseTab(_ sender: NSButton) {
		if let item = _selectedTab {
			closeTab(tab: item)
		}
	}
	
	@IBAction func onAddGraph(_ sender: NSButton) {
		let graph = _story.makeGraph(name: NSUUID().uuidString)
		do { try _story.add(graph: graph) } catch {
			alertError(message: "Could not add Graph!", info: "Adding a graph to the Story failed.")
			return // TODO: Remove graph
		}
		let newTab = addNewTab(forGraph: graph)
		selectTab(item: newTab)
		
		reloadBrowser()
	}
	
	@IBAction func onUndo(_ sender: NSButton) {
		getActiveGraph()?.undo()
	}
	
	@IBAction func onRedo(_ sender: NSButton) {
		getActiveGraph()?.redo()
	}
	
	@IBAction func onEditedStoryName(_ sender: NSTextField) {
		_story.Name = sender.stringValue
	}
	
	// MARK: - - Story Browser Functions -
	func reloadBrowser() {
		_storyBrowser.reloadData()
	}
}

// MARK: - - NVStoryDelegate -
extension MainViewController: NVStoryDelegate {
	func onStoryMakeFolder(folder: NVFolder) {
		reloadBrowser()
	}
	func onStoryMakeVariable(variable: NVVariable) {
		reloadBrowser()
	}
	func onStoryMakeGraph(graph: NVGraph) {
		reloadBrowser()
	}
	func onStoryMakeLink(link: NVLink) {
		reloadBrowser()
	}
	func onStoryMakeBranch(branch: NVBranch) {
		reloadBrowser()
	}
	func onStoryMakeSwitch(switch: NVSwitch) {
		reloadBrowser()
	}
	func onStoryMakeDialog(dialog: NVDialog) {
		reloadBrowser()
	}
	func onStoryAddFolder(folder: NVFolder) {
		reloadBrowser()
	}
	func onStoryRemoveFolder(folder: NVFolder) {
		reloadBrowser()
	}
	func onStoryAddGraph(graph: NVGraph) {
		reloadBrowser()
	}
	func onStoryRemoveGraph(graph: NVGraph) {
		reloadBrowser()
	}
}

// MARK: - - GraphViewDelegate -
extension MainViewController: GraphViewDelegate {
	func onLinkAdded(link: PinViewLink) {
		print("GraphView added link.")
	}
	
	func onBranchAdded(branch: PinViewBranch) {
		print("GraphView added branch.")
	}
	
	func onDialogAdded(dialog: DialogLinkableView) {
		print("GraphView added dialog.")
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
			// if graph is open, switch to it
			if let tab = getTabForGraph(graph: asGraph) {
				selectTab(item: _tabs.first(where: {$0.tabItem == tab}))
			} else {
				_ = addNewTab(forGraph: asGraph)
				selectTab(item: _tabs[_tabs.count-1])
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
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if item is String {
			return true
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		if let asString = item as? String {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = asString
		} else {
			var name = "error"
			var icon: NSImage? = nil
			switch item {
			case is NVFolder:
				name = (item as! NVFolder).Name
				icon = _folderIcon
				
			case is NVVariable:
				name = (item as! NVVariable).Name
				icon = _variableIcon
				
			case is NVGraph:
				name = (item as! NVGraph).Name
				icon = _graphIcon
				
			case is NVDialog:
				name = (item as! NVDialog).Name
				icon = _dialogIcon
				
			case is NVLink:
				let from = _story.getNameOf(linkable: (item as! NVLink).Origin)
				let to = _story.getNameOf(linkable: (item as! NVLink).Transfer.Destination)
				name = "\(from) => \(to)"
				icon = nil
				
			case is NVBranch:
				let from = _story.getNameOf(linkable: (item as! NVBranch).Origin)
				let toTrue = _story.getNameOf(linkable: (item as! NVBranch).TrueTransfer.Destination)
				let toFalse = _story.getNameOf(linkable: (item as! NVBranch).FalseTransfer.Destination)
				name = "\(from) => T=\(toTrue); F=\(toFalse)"
				icon = nil
				
			default:
				break
			}
			
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
			view?.textField?.stringValue = name
			view?.imageView?.image = icon
		}
		
		return view
	}
}

extension MainViewController {
	func selectTab(item: TabItem?) {
		// update selected tab
		_selectedTab = item
		// get index
		if _selectedTab != nil, let index = _tabs.index(of: _selectedTab!) {
			_tabController.selectItemAtIndex(index)
			onSelectedTabChanged()
		} else {
			_tabController.selectItemAtIndex(-1) // invalid clears selection
		}
	}
	
	func onSelectedTabChanged() {
		_tabView.selectTabViewItem(_selectedTab?.tabItem)
	}
}
extension MainViewController: TabsControlDelegate {
	func tabsControl(_ control: TabsControl, didReorderItems items: [AnyObject]) {
	}
	func tabsControl(_ control: TabsControl, canEditTitleOfItem item: AnyObject) -> Bool {
		return true
	}
	func tabsControl(_ control: TabsControl, setTitle newTitle: String, forItem item: AnyObject) {
		let tabItem = (item as! TabItem)
		let oldName = tabItem.title
		
		if let nvGraph = getGraphViewFromTab(tab: tabItem.tabItem)?.NovellaGraph {
			do {
				try nvGraph.setName(newTitle)
				tabItem.title = newTitle
			} catch {
				tabItem.title = oldName
				control.reloadTabs() // must reload if it failed to update the tab again
			}
		}
		
		reloadBrowser()
	}
	
	func tabsControl(_ control: TabsControl, canSelectItem item: AnyObject) -> Bool {
		return (item as! TabItem).selectable
	}
	
	func tabsControl(_ control: TabsControl, canReorderItem item: AnyObject) -> Bool {
		// If this is true, there's a bug when selecting tabs (i maybe can fix and PR it).
		// If true and you call selectItemAtIndex() (during a mousedown event like click button?), then
		// it will eventually call selectTab(), which for some unknown reason goes into reorder mode, and until
		// you click on the window to disable it, will hang your program as if it's in async mode.  This causes
		// fairly severe issues as code after the above call WON'T execute until after clicking again, but
		// the function does return.
		return false
	}
	
	func tabsControlDidChangeSelection(_ control: TabsControl, item: AnyObject) {
		_selectedTab = (item as! TabItem)
		onSelectedTabChanged()
	}
	
}
extension MainViewController: TabsControlDataSource {
	func tabsControlNumberOfTabs(_ control: TabsControl) -> Int {
		return _tabs.count
	}
	
	func tabsControl(_ control: TabsControl, itemAtIndex index: Int) -> AnyObject {
		return _tabs[index]
	}
	
	func tabsControl(_ control: TabsControl, titleForItem item: AnyObject) -> String {
		return (item as! TabItem).title
	}
	
	func tabsControl(_ control: TabsControl, menuForItem item: AnyObject) -> NSMenu? {
		return (item as! TabItem).menu
	}
	
	func tabsControl(_ control: TabsControl, iconForItem item: AnyObject) -> NSImage? {
		return (item as! TabItem).icon
	}
	
	func tabsControl(_ control: TabsControl, titleAlternativeIconForItem item: AnyObject) -> NSImage? {
		return (item as! TabItem).altIcon
	}
}

