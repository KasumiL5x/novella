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
	// MARK: - Variables -
	private var _appeared: Bool = false
	private var _document: NovellaDocument!
	private var _selectedTab: TabItem?
	
	// MARK: - Outlets -
	@IBOutlet private weak var _splitView: NSSplitView!
	@IBOutlet private weak var _tabView: NSTabView!
	@IBOutlet private weak var _tabController: TabsControl!
	@IBOutlet private weak var _inspector: NSTableView!
	@IBOutlet private weak var _allGraphsOutline: AllGraphsOutlineView!
	@IBOutlet private weak var _selectedGraphOutline: SelectedGraphOutlineView!
	@IBOutlet private weak var _selectedGraphName: NSTextField!
	
	// MARK: - Delegates & Data Sources -
	private var _storyDelegate: StoryDelegate?
	private var _tabsDataSource: TabsDataSource?
	private var _inspectorDataDelegate: InspectorDataSource?
	private var _allGraphsDelegate: AllGraphsDelegate?
	private var _selectedGraphDelegate: SelectedGraphDelegate?
	
	// MARK: - Properties -
	var Document: NovellaDocument {
		get{ return _document }
	}
	var InspectorDelegate: InspectorDataSource? {
		get{ return _inspectorDataDelegate }
	}
	var Undo: UndoRedo? {
		get{ return _document?.Undo }
	}
	
	// MARK: - Initialization -
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
		_tabController.style = SafariStyle()
		_tabController.delegate = self
		_tabController.dataSource = _tabsDataSource
		_tabController.reloadTabs()
		
		// set outline view BG colors as there seems to be an IB bug where the color is just *slightly* not maintained
		_allGraphsOutline.backgroundColor = NSColor.fromHex("#ECECEC")
		_selectedGraphOutline.backgroundColor = NSColor.fromHex("#ECECEC")
	}
	
	override func viewWillAppear() {
		if !_appeared {
			// _document canNOT be used before this point
			self._document = view.window?.windowController?.document as? NovellaDocument
			self._document.Manager.addDelegate(_storyDelegate!)
			
			// outliners
			_allGraphsOutline.MVC = self
			_allGraphsOutline.dataSource = _allGraphsDelegate
			_allGraphsOutline.delegate = _allGraphsDelegate
			_selectedGraphOutline.MVC = self
			_selectedGraphOutline.delegate = _selectedGraphDelegate
			_selectedGraphOutline.dataSource = _selectedGraphDelegate
			
			// inspector
			_inspector.dataSource = _inspectorDataDelegate
			_inspector.delegate = _inspectorDataDelegate
			
			reloadAllGraphs()
			reloadSelectedGraph()
			
			_appeared = true
		}
	}
	
	// MARK: Functions
	func screenshot() {
		if let img = getActiveGraph()?.screenshot(), let imageData = img.tiffRepresentation {
			let imageRep = NSBitmapImageRep(data: imageData)
			let imageProps = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
			let finalData = imageRep?.representation(using: .jpeg, properties: imageProps)
			
			let sp = NSSavePanel()
			sp.allowedFileTypes = ["jpg"]
			if sp.runModal() != NSApplication.ModalResponse.OK {
				return
			}
			
			do { try finalData?.write(to: sp.url!, options: []) } catch {
				print("MainViewController::screenshot(): Failed to write file.")
			}
		}
	}
	
	func refreshOpenGraphs() {
		for t in _tabsDataSource!.Tabs {
			getGraphViewFromTab(tab: t.tabItem)?.redrawAll()
		}
	}
	
	// MARK: Interface Callbacks
	@IBAction func onOutlinerAddGraph(_ sender: NSButton) {
		addGraph(parent: nil)
	}
	@IBAction func onAllGraphsNameChanged(_ sender: NSTextField) {
		guard let graph = _allGraphsOutline.item(atRow: _allGraphsOutline.selectedRow) as? NVGraph else {
			return
		}
		graph.Name = sender.stringValue
		reloadSelectedGraph()
		getTabItemFor(graph: graph)?.title = graph.Name
		_tabController.reloadTabs()
	}
}

// MARK: - Outliner -
extension MainViewController {
	func reloadAllGraphs() {
		_allGraphsOutline.reloadData()
	}
	
	func reloadSelectedGraph() {
		_selectedGraphOutline.reloadData()
		_selectedGraphName.stringValue = _selectedGraphDelegate?.Graph?.Name ?? ""
	}
	
	func setSelectedGraph(graph: NVGraph?) {
		_selectedGraphDelegate?.Graph = graph
		reloadSelectedGraph()
		
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
}

// MARK: - Inspector -
extension MainViewController {
	func reloadInspector() {
		_inspectorDataDelegate!.refresh()
		_inspector.reloadData()
	}
}

// MARK: - Helper Functions -
extension MainViewController {
	func addGraph(parent: NVGraph?) {
		let graph = _document.Manager.makeGraph(name: NSUUID().uuidString)
		if parent == nil {
			try! _document.Manager.Story.add(graph: graph)
		} else {
			try! parent!.add(graph: graph)
		}
		let newTab = addNewTab(forGraph: graph)
		selectTab(item: newTab)
		
		reloadAllGraphs()
		_allGraphsOutline.selectRowIndexes([_allGraphsOutline.row(forItem: graph)], byExtendingSelection: false)
		reloadSelectedGraph()
	}
	
	func openVariableEditor() {
		if let existing = _tabsDataSource!.Tabs.first(where: {$0.tabItem.viewController is VariableTabViewController}) {
			selectTab(item: existing)
		} else {
			let varTab = addVariableTabEditor()
			selectTab(item: varTab)
		}
	}
	
	func openEntityEditor() {
		if let existing = _tabsDataSource!.Tabs.first(where: {$0.tabItem.viewController is EntityTabViewController}) {
			selectTab(item: existing)
		} else {
			let entityTab = addEntityTabEditor()
			selectTab(item: entityTab)
		}
	}
}

// MARK: - - Tabs -
extension MainViewController {
	@discardableResult
	private func addNewTab(forGraph: NVGraph) -> TabItem? {
		let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "TabPages"), bundle: nil)
		let id = NSStoryboard.SceneIdentifier(rawValue: "GraphTab")
		guard let vc = sb.instantiateController(withIdentifier: id) as? GraphTabViewController else {
			print("Failed to initialize GraphTabViewController.")
			return nil
		}
		vc.setup(doc: _document, graph: forGraph, delegate: self)
		let tabViewItem = NSTabViewItem(viewController: vc)
		_tabView.addTabViewItem(tabViewItem)
		
		let tabItem = TabItem(title: forGraph.Name, icon: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		tabItem.closeFunc = { (item) in
			self.closeTab(tab: item)
		}
		_tabsDataSource!.Tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	@discardableResult
	private func addVariableTabEditor() -> TabItem? {
		let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "TabPages"), bundle: nil)
		let id = NSStoryboard.SceneIdentifier(rawValue: "VariableTab")
		guard let vc =  sb.instantiateController(withIdentifier: id) as? VariableTabViewController else {
			print("Failed to initialize VariableTabViewController.")
			return nil
		}
		vc.setup(doc: _document)
		let tabViewItem = NSTabViewItem(viewController: vc)
		_tabView.addTabViewItem(tabViewItem)
		
		let tabItem = TabItem(title: "Variable Editor", icon: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		tabItem.closeFunc = { (item) in
			self.closeTab(tab: item)
		}
		_tabsDataSource!.Tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	@discardableResult
	private func addEntityTabEditor() -> TabItem? {
		let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "TabPages"), bundle: nil)
		let id = NSStoryboard.SceneIdentifier(rawValue: "EntityTab")
		guard let vc = sb.instantiateController(withIdentifier: id) as? EntityTabViewController else {
			print("Failed to initialize EntityTabViewController.")
			return nil
		}
		let tabViewItem = NSTabViewItem(viewController: vc)
		_tabView.addTabViewItem(tabViewItem)
		
		let tabItem = TabItem(title: "Entity Editor", icon: nil, altIcon: nil, tabItem: tabViewItem, selectable: true)
		tabItem.closeFunc = { (item) in
			self.closeTab(tab: item)
		}
		_tabsDataSource!.Tabs.append(tabItem)
		_tabController.reloadTabs()
		
		return tabItem
	}
	
	private func closeTab(tab: TabItem) {
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
	
	private func closeAllTabs() {
		_tabsDataSource!.Tabs = []
		_selectedTab = nil
		_tabController.reloadTabs()
		
		for curr in _tabView.tabViewItems.reversed() {
			_tabView.removeTabViewItem(curr)
		}
	}
	
	private func selectTab(item: TabItem?) {
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
	
	private func onSelectedTabChanged() {
		_tabView.selectTabViewItem(_selectedTab?.tabItem)
	}
	
	private func getGraphViewFromTab(tab: NSTabViewItem) -> GraphView? {
		// must have correct VC
		guard let vc = tab.viewController as? GraphTabViewController else {
			return nil
		}
		return vc.Graph
	}
	
	func getActiveGraph() -> GraphView? {
		if let selectedTab = _selectedTab {
			return getGraphViewFromTab(tab: selectedTab.tabItem)
		}
		return nil
	}
	
	private func getTabItemFor(graph: NVGraph) -> TabItem? {
		return _tabsDataSource!.Tabs.first(where: {
			guard let graphView = getGraphViewFromTab(tab: $0.tabItem) else {
				return false
			}
			return graphView.NovellaGraph == graph
		})
	}
	
	private func getTabForGraph(graph: NVGraph) -> NSTabViewItem? {
		return getTabItemFor(graph: graph)?.tabItem
	}
	
	func zoomActiveGraph() {
		if let selectedTab = _selectedTab, let graphVC = selectedTab.tabItem.viewController as? GraphTabViewController {
			if !graphVC.zoomSelected() {
				_ = graphVC.zoomAll()
			}
		}
	}
	
	func centerActiveGraph() {
		if let selectedTab = _selectedTab, let graphVC = selectedTab.tabItem.viewController as? GraphTabViewController {
			graphVC.centerView(animated: true)
		}
	}
	
	func undo() {
		getActiveGraph()?.undo()
	}
	
	func redo() {
		getActiveGraph()?.redo()
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

// MARK: - NSSplitViewDelegate -
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

// MARK: - GraphViewDelegate -
extension MainViewController: GraphViewDelegate {
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
