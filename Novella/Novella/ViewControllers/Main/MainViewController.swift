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

class MainViewController: NSViewController {
	// MARK: - - Constants -
	fileprivate static let SCROLL_SIZE: CGFloat = 6000.0
	fileprivate static let MIN_ZOOM: CGFloat = 0.2
	fileprivate static let MAX_ZOOM: CGFloat = 4.0
	
	// MARK: - - Variables -
	fileprivate var _openedFile: URL?
	fileprivate var _selectedTab: TabItem?
	fileprivate var _browserTopLevel: [String] = [
		"Graphs",
		"Variables"
	]
	
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _splitView: NSSplitView!
	@IBOutlet fileprivate weak var _tabView: NSTabView!
	@IBOutlet fileprivate weak var _storyName: NSTextField!
	@IBOutlet fileprivate weak var _tabController: TabsControl!
	@IBOutlet private weak var _inspector: NSTableView!
	@IBOutlet private weak var _allGraphsOutline: AllGraphsOutlineView!
	@IBOutlet fileprivate weak var _selectedGraphOutline: NSOutlineView!
	@IBOutlet fileprivate weak var _selectedGraphName: NSTextField!
	
	// MARK: - - Delegates & Data Sources -
	fileprivate var _storyDelegate: StoryDelegate?
	fileprivate var _tabsDataSource: TabsDataSource?
	fileprivate var _inspectorDataDelegate: InspectorDataSource?
	fileprivate var _allGraphsDelegate: AllGraphsDelegate?
	fileprivate var _selectedGraphDelegate: SelectedGraphDelegate?
	
	// MARK: - - Properties -
	var InspectorDelegate: InspectorDataSource? {
		get{ return _inspectorDataDelegate }
	}
	
	
	// MARK: - _TESTING_ -
	func setSelectedGraph(graph: NVGraph?) {
		_selectedGraphDelegate?.Graph = graph
		_selectedGraphName.stringValue = graph?.Name ?? ""
		_selectedGraphOutline.reloadData()
		
		// handle opening of graph view
		if let graph = graph {
			// if a tab is open, switch to it
			if let tab = getTabForGraph(graph: graph) {
				selectTab(item: _tabsDataSource!.Tabs.first(where: {$0.tabItem == tab}))
			} else {
				_ = addNewTab(forGraph: graph)
				selectTab(item: _tabsDataSource!.Tabs[_tabsDataSource!.Tabs.count-1])
			}
		}
	}
	
	// MARK: - - Initialization -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// delegates and data sources
		_storyDelegate = StoryDelegate(mvc: self)
		_tabsDataSource = TabsDataSource()
		_inspectorDataDelegate = InspectorDataSource()
		_allGraphsDelegate = AllGraphsDelegate(mvc: self)
		_selectedGraphDelegate = SelectedGraphDelegate(mvc: self)
		
		// split view
		_splitView.delegate = self
		
		// tab controller
		_selectedTab = nil
		_tabController.style = ChromeStyle()
		_tabController.delegate = self
		_tabController.dataSource = _tabsDataSource
		_tabController.reloadTabs()
		
		// inspector
		_inspector.dataSource = _inspectorDataDelegate
		_inspector.delegate = _inspectorDataDelegate
		
		// outliners
		_allGraphsOutline.MVC = self
		_allGraphsOutline.dataSource = _allGraphsDelegate
		_allGraphsOutline.delegate = _allGraphsDelegate
		_selectedGraphOutline.delegate = _selectedGraphDelegate
		_selectedGraphOutline.dataSource = _selectedGraphDelegate
		
		// start with an empty story
		createEmptyStory()
	}
	
	// MARK: - - Functions called from window -
	func onNew() {
		let saveAlertResult = alertSave(message: "Save Before New?", info: "Making a new Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory(false) {
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
		
		reloadAllGraphs()
		setSelectedGraph(graph: nil)
		reloadInspector()
	}

	func onOpen() {
		let saveAlertResult = alertSave(message: "Save Before Open?", info: "Opening a Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory(false) {
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
		if NVStoryManager.fromJSON(str: contents) {
			NVStoryManager.shared.addDelegate(_storyDelegate!)
		} else {
			alertError(message: "Failed to load Story.", info: "Failed to load the story.")
			return
		}
		
		// close any current tabs
		closeAllTabs()
		
		// add a new graph tab for each subgraph of the story
		for curr in NVStoryManager.shared.Story.Graphs {
			addNewTab(forGraph: curr)
		}
		// select first tab
		if _tabsDataSource!.Tabs.count > 0 {
			_tabController.reloadTabs()
			selectTab(item: _tabsDataSource!.Tabs[0])
		}
		
		// store file url for saving
		_openedFile = ofd.url!
		
		// story name
		_storyName.stringValue = NVStoryManager.shared.Story.Name
		
		reloadAllGraphs()
		setSelectedGraph(graph: nil)
		reloadInspector()
	}
	
	func onSave(forcePrompt: Bool) {
		_ = saveStory(forcePrompt)
	}
	
	func onClose() {
		let saveAlertResult = alertSave(message: "Save Before Close?", info: "Closing the Story will lose any unsaved changes.  Do you want to save first?")
		switch saveAlertResult {
		case .cancel:
			return
		case .save:
			if !saveStory(false) {
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
		
		reloadAllGraphs()
		setSelectedGraph(graph: nil)
		reloadInspector()
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
	func addGraph(parent: NVGraph?) {
		let graph = NVStoryManager.shared.makeGraph(name: NSUUID().uuidString)
		
		if parent == nil {
			try! NVStoryManager.shared.Story.add(graph: graph)
		} else {
			try! parent!.add(graph: graph)
		}
		let newTab = addNewTab(forGraph: graph)
		selectTab(item: newTab)
		
		reloadAllGraphs()
		reloadSelectedGraph()
	}
	
	fileprivate func saveStory(_ forcePrompt: Bool) -> Bool {
		if _openedFile == nil || forcePrompt {
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
		let jsonString = NVStoryManager.shared.toJSON()
		if jsonString == "" {
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
		
		let toastSettings = ToastSettings()
		self.view.showToast(message: "Saved", userSettings: toastSettings)
		
		return true
	}
	fileprivate func createEmptyStory() {
		// close existing tabs
		closeAllTabs()
		// create a new story
		NVStoryManager.shared.reset()
		NVStoryManager.shared.addDelegate(_storyDelegate!)
	}
	
	// MARK: - - Tabs/TabView Functions -
	@discardableResult
	fileprivate func addNewTab(forGraph: NVGraph) -> TabItem? {
		let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "TabPages"), bundle: nil)
		let id = NSStoryboard.SceneIdentifier(rawValue: "GraphTab")
		guard let vc =  sb.instantiateController(withIdentifier: id) as? GraphTabViewController else {
			print("Failed to initialize GraphTabViewController.")
			return nil
		}
		vc.setup(graph: forGraph, delegate: self)
		let tabViewItem = NSTabViewItem(viewController: vc)
		_tabView.addTabViewItem(tabViewItem)
		
		let tabItem = TabItem(title: forGraph.Name, icon: nil, menu: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		_tabsDataSource!.Tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	@discardableResult
	fileprivate func addVariableTabEditor() -> TabItem? {
		let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "TabPages"), bundle: nil)
		let id = NSStoryboard.SceneIdentifier(rawValue: "VariableTab")
		guard let vc =  sb.instantiateController(withIdentifier: id) as? VariableTabViewController else {
			print("Failed to initialize VariableTabViewController.")
			return nil
		}
		let tabViewItem = NSTabViewItem(viewController: vc)
		_tabView.addTabViewItem(tabViewItem)
		
		let tabItem = TabItem(title: "Variable Editor", icon: nil, menu: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		_tabsDataSource!.Tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	fileprivate func closeTab(tab: TabItem) {
		guard let index = _tabsDataSource!.Tabs.index(of: tab) else { return }
		
		// re-assign selected tab if this tab was selected
		if _selectedTab == tab {
			// behavior of KPCTabsControl seems to be select to right if it exists, but don't select left and instead give nil
			_selectedTab = (index+1 >= _tabsDataSource!.Tabs.count) ? nil : _tabsDataSource!.Tabs[index+1]
		}
		
		// remove from tabs array
		_tabsDataSource!.Tabs.remove(at: index)
		
		// refresh tab control
		_tabController.reloadTabs()
		
		// remove from actual tab view
		_tabView.removeTabViewItem(tab.tabItem)
	}
	
	fileprivate func closeAllTabs() {
		_tabsDataSource!.Tabs = []
		_selectedTab = nil
		_tabController.reloadTabs()
		
		for curr in _tabView.tabViewItems.reversed() {
			_tabView.removeTabViewItem(curr)
		}
	}
	
	fileprivate func getGraphViewFromTab(tab: NSTabViewItem) -> GraphView? {
		// must have correct VC
		guard let vc = tab.viewController as? GraphTabViewController else {
			return nil
		}
		return vc.Graph
	}
	
	fileprivate func getActiveGraph() -> GraphView? {
		if let selectedTab = _selectedTab {
			return getGraphViewFromTab(tab: selectedTab.tabItem)
		}
		return nil
	}
	
	fileprivate func getTabForGraph(graph: NVGraph) -> NSTabViewItem? {
		return _tabsDataSource!.Tabs.first(where: {
			guard let graphView = getGraphViewFromTab(tab: $0.tabItem) else {
				return false
			}
			return graphView.NovellaGraph == graph
		})?.tabItem
	}
	
	// MARK: - - Interface Buttons -
	@IBAction func onAddGraph(_ sender: NSButton) {
		addGraph(parent: nil)
	}
	
	@IBAction func onTrashItem(_ sender: NSButton) {
		print("Need to reimplement this.")
//		let selectedRow = _storyBrowser.selectedRow
//		let item = _storyBrowser.item(atRow: selectedRow)
//		if item == nil {
//			return
//		}
//
//		if var trashable = item as? NVLinkable {
//			let inTrash = trashable.Trashed
//			trashable.Trashed = !inTrash
//			_storyBrowser.selectRowIndexes(.init(integer: selectedRow), byExtendingSelection: false)
//		}
	}
	
	@IBAction func onEmptyTrash(_ sender: NSButton) {
		NVStoryManager.shared.emptyTrash()
	}
	
	@IBAction func onVariableEditor(_ sender: NSButton) {
		if let existing = _tabsDataSource!.Tabs.first(where: {$0.tabItem.viewController is VariableTabViewController}) {
			selectTab(item: existing)
		} else {
			let varTab = addVariableTabEditor()
			selectTab(item: varTab)
		}
	}
	
	@IBAction func onCloseTab(_ sender: NSButton) {
		if let item = _selectedTab {
			closeTab(tab: item)
		}
	}
	
	@IBAction func onUndo(_ sender: NSButton) {
		getActiveGraph()?.undo()
	}
	
	@IBAction func onRedo(_ sender: NSButton) {
		getActiveGraph()?.redo()
	}
	
	@IBAction func onEditedStoryName(_ sender: NSTextField) {
		NVStoryManager.shared.Story.Name = sender.stringValue
	}
	
	// MARK: - - Outliner Functions -
	func reloadAllGraphs() {
		_allGraphsOutline.reloadData()
	}
	func reloadSelectedGraph() {
		_selectedGraphOutline.reloadData()
	}
}

// MARK: - - Story Browser -
extension MainViewController {
//	@objc fileprivate func onStoryBrowserDoubleClick() {
//		let clickedRow = _storyBrowser.clickedRow
//		if -1 == clickedRow {
//			return
//		}
//
//		let clickedItem = _storyBrowser.item(atRow: clickedRow)
//
//		if let asGraph = clickedItem as? NVGraph {
//			// if graph is open, switch to it
//			if let tab = getTabForGraph(graph: asGraph) {
//				selectTab(item: _tabsDataSource!.Tabs.first(where: {$0.tabItem == tab}))
//			} else {
//				_ = addNewTab(forGraph: asGraph)
//				selectTab(item: _tabsDataSource!.Tabs[_tabsDataSource!.Tabs.count-1])
//			}
//		}
//	}
}

// MARK: - - Tabs -
extension MainViewController {
	func selectTab(item: TabItem?) {
		// update selected tab
		_selectedTab = item
		// get index
		if _selectedTab != nil, let index = _tabsDataSource!.Tabs.index(of: _selectedTab!) {
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
		return (item as! TabItem).tabItem.viewController is GraphTabViewController
	}
	func tabsControl(_ control: TabsControl, setTitle newTitle: String, forItem item: AnyObject) {
		let tabItem = (item as! TabItem)
		
		switch tabItem.tabItem.viewController {
		case is GraphTabViewController:
			if let nvGraph = getGraphViewFromTab(tab: tabItem.tabItem)?.NovellaGraph {
				nvGraph.Name = newTitle
				tabItem.title = newTitle
			}
			reloadAllGraphs()
			reloadSelectedGraph()
			
		default:
			print("Unexpected ViewController type for renamed tab.")
			break
		}
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

// MARK: - - NSSplitViewDelegate -
extension MainViewController: NSSplitViewDelegate {
	func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
		let subviews = splitView.subviews
		let count = subviews.count
		if count < 1 {
			return false
		}
		if (subview == subviews[0]) || (subview == subviews[count-1]) {
			return true
		}
		
		return false
	}
	
	func splitView(_ splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAt dividerIndex: Int) -> Bool {
		return true
	}
	
	func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
		if dividerIndex == 0 {
			return proposedMinimumPosition + 150.0
		}
		return proposedMinimumPosition
	}
	
	func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
		if dividerIndex == (splitView.subviews.count-2) { // number of subviews - 1 is the number of dividers, so -2 to get the last divider
			return proposedMaximumPosition - 150.0
		}
		return proposedMaximumPosition
	}
}

// MARK: - - GraphViewDelegate -
extension MainViewController: GraphViewDelegate {
	func reloadInspector() {
		_inspectorDataDelegate!.refresh()
		_inspector.reloadData()
	}
	
	func onSelectionChanged(graphView: GraphView, selection: [LinkableView]) {
		if selection.isEmpty {
			_inspectorDataDelegate!.setTarget(target: nil)
		} else if selection.count == 1 {
			let item = selection[0]
			switch item {
			case is DialogLinkableView:
				_inspectorDataDelegate!.setTarget(target: (item.Linkable as! NVDialog))
			case is DeliveryLinkableView:
				_inspectorDataDelegate!.setTarget(target: (item.Linkable as! NVDelivery))
			case is ContextLinkableView:
				_inspectorDataDelegate!.setTarget(target: (item.Linkable as! NVContext))
			case is GraphLinkableView:
				_inspectorDataDelegate!.setTarget(target: (item.Linkable as! NVGraph))
			default:
				break
			}
		} else {
			_inspectorDataDelegate!.setTarget(target: nil) // cannot handle selection of multiple items
		}
		
		reloadInspector()
	}
}
