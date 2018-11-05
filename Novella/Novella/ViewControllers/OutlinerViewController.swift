//
//  OutlinerViewController.swift
//  novella
//
//  Created by Daniel Green on 22/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class OutlinerOutlineView: NSOutlineView, NVStoryDelegate {
	private var _menu: NSMenu!
	var Doc: Document? {
		didSet {
			Doc?.Story.addDelegate(self)
		}
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		_menu = NSMenu()
		_menu.addItem(withTitle: "New Dialog", action: #selector(OutlinerOutlineView.onMenuNewDialog), keyEquivalent: "")
		_menu.addItem(withTitle: "New Delivery", action: #selector(OutlinerOutlineView.onMenuNewDelivery), keyEquivalent: "")
		_menu.addItem(withTitle: "New Context", action: #selector(OutlinerOutlineView.onMenuNewContext), keyEquivalent: "")
		_menu.addItem(withTitle: "New Branch", action: #selector(OutlinerOutlineView.onMenuNewBranch), keyEquivalent: "")
		_menu.addItem(withTitle: "New Switch", action: #selector(OutlinerOutlineView.onMenuNewSwitch), keyEquivalent: "")
		_menu.addItem(withTitle: "New Graph", action: #selector(OutlinerOutlineView.onMenuNewGraph), keyEquivalent: "")
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		return _menu
	}
	
	@objc private func onMenuNewDialog() {
		NotificationCenter.default.post(name: .canvasAddDialog, object: nil)
	}
	@objc private func onMenuNewDelivery() {
		NotificationCenter.default.post(name: .canvasAddDelivery, object: nil)
	}
	@objc private func onMenuNewContext() {
		NotificationCenter.default.post(name: .canvasAddContext, object: nil)
	}
	@objc private func onMenuNewBranch() {
		NotificationCenter.default.post(name: .canvasAddBranch, object: nil)
	}
	@objc private func onMenuNewSwitch() {
		NotificationCenter.default.post(name: .canvasAddSwitch, object: nil)
	}
	@objc private func onMenuNewGraph() {
		guard let doc = Doc, let parentGraph = parentGraphOfSelection() else {
			return
		}
		let newGraph = doc.Story.makeGraph(name: NSUUID().uuidString)
		parentGraph.add(graph: newGraph)
		
		self.reloadData()
	}
	
	func parentGraphOfSelection() -> NVGraph? {
		let item = self.item(atRow: self.selectedRow)
		
		// directly a graph
		if item is NVGraph {
			return (item as! NVGraph)
		}
		
		// dig up until we find one
		var theParent: Any? = self.parent(forItem: item)
		while theParent != nil {
			if theParent is NVGraph {
				return (theParent as! NVGraph)
			}
			theParent = self.parent(forItem: theParent)
		}
		
		// give up
		return nil
	}
	
	private func deleteEntryFor(obj: Any) {
		let childIdx = self.childIndex(forItem: obj)
		if -1 == childIdx {
			return
		}
		let parent = self.parent(forItem: obj)
		self.removeItems(at: IndexSet(integer: childIdx), inParent: parent, withAnimation: [.effectFade, .slideLeft])
		self.reloadItem(parent) // reload only the parent to reset the expansion triangle while still maintaining selection (if the selection wasn't removed)
	}
	
	// MARK: NVStoryDelegate
	// renaming
	func nvGraphDidRename(graph: NVGraph) {
		self.reloadItem(graph)
	}
	func nvNodeDidRename(node: NVNode) {
		self.reloadItem(node)
	}
	// creation
	func nvStoryDidCreateGraph(graph: NVGraph) {
		self.reloadData()
	}
	func nvStoryDidCreateLink(link: NVLink) {
		self.reloadData()
	}
	func nvStoryDidCreateBranch(branch: NVBranch) {
		self.reloadData()
	}
	func nvStoryDidCreateSwitch(swtch: NVSwitch) {
		self.reloadData()
	}
	func nvStoryDidCreateDialog(dialog: NVDialog) {
		self.reloadData()
	}
	func nvStoryDidCreateDelivery(delivery: NVDelivery) {
		self.reloadData()
	}
	
	// add to graph
	func nvGraphDidAddLink(graph: NVGraph, link: NVLink) {
		self.reloadData()
	}
	func nvGraphDidAddNode(parent: NVGraph, child: NVNode) {
		self.reloadData()
	}
	func nvGraphDidAddGraph(parent: NVGraph, child: NVGraph) {
		self.reloadData()
	}
	func nvGraphDidAddSwitch(graph: NVGraph, swtch: NVSwitch) {
		self.reloadData()
	}
	func nvGraphDidAddBranch(graph: NVGraph, branch: NVBranch) {
		self.reloadData()
	}
	// remove from graph
	func nvGraphDidRemoveLink(graph: NVGraph, link: NVLink) {
		deleteEntryFor(obj: link)
	}
	func nvGraphDidRemoveNode(parent: NVGraph, child: NVNode) {
		deleteEntryFor(obj: child)
	}
	func nvGraphDidRemoveGraph(parent: NVGraph, child: NVGraph) {
		deleteEntryFor(obj: child)
	}
	func nvGraphDidRemoveSwitch(graph: NVGraph, swtch: NVSwitch) {
		deleteEntryFor(obj: swtch)
	}
	func nvGraphDidRemoveBranch(graph: NVGraph, branch: NVBranch) {
		deleteEntryFor(obj: branch)
	}
	
	// deletion
	func nvStoryDidDeleteNode(node: NVNode) {
		deleteEntryFor(obj: node)
	}
	func nvStoryDidDeleteLink(link: NVLink) {
		deleteEntryFor(obj: link)
	}
	func nvStoryDidDeleteBranch(branch: NVBranch) {
		deleteEntryFor(obj: branch)
	}
	func nvStoryDidDeleteSwitch(swtch: NVSwitch) {
		deleteEntryFor(obj: swtch)
	}
	func nvStoryDidDeleteGraph(graph: NVGraph) {
		deleteEntryFor(obj: graph)
	}
}

class OutlinerViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _outlineView: OutlinerOutlineView!
	
	// MARK: - Variables
	private var _graphIcon: NSImage?
	private var _linkIcon: NSImage?
	private var _branchIcon: NSImage?
	private var _switchIcon: NSImage?
	private var _dialogIcon: NSImage?
	private var _deliveryIcon: NSImage?
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			_outlineView.Doc = Doc
			_outlineView.reloadData()
		}
	}
	
	var onItemSelected: ((_ item: Any, _ parentGraph: NVGraph) -> ())?
	
	override func viewDidLoad() {
		_graphIcon = NSImage(named: "Graph")
		_linkIcon = NSImage(named: "Link")
		_branchIcon = NSImage(named: "Branch")
		_switchIcon = NSImage(named: "Switch")
		_dialogIcon = NSImage(named: "Dialog")
		_deliveryIcon = NSImage(named: "Delivery")
		
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	override func viewDidAppear() {
		_outlineView.reloadData()
	}
	
	@IBAction func onOutlinerSelectionChanged(_ sender: NSOutlineView) {
		let idx = sender.selectedRow
		guard let item = sender.item(atRow: idx), let parentGraph = _outlineView.parentGraphOfSelection() else {
			return
		}
		
		onItemSelected?(item, parentGraph)
	}
}

extension OutlinerViewController: NSOutlineViewDelegate {
	// custom row class
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return VariablesTableRowView(frame: NSRect.zero) // reuse variables for consistency
	}
	
	// color odd/even rows
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
        if row % 2 == 0 {
            rowView.backgroundColor = Colors.TableRowEven
        } else {
            rowView.backgroundColor = Colors.TableRowOdd
        }
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "OutlinerCell"), owner: self) as? NSTableCellView

		switch item {
		case let asGraph as NVGraph:
			(view as? NSTableCellView)?.textField?.stringValue = asGraph.Name
			(view as? NSTableCellView)?.imageView?.image = _graphIcon
		case let asNode as NVNode:
			(view as? NSTableCellView)?.textField?.stringValue = asNode.Name
			switch asNode {
			case is NVDialog:
				(view as? NSTableCellView)?.imageView?.image = _dialogIcon
			case is NVDelivery:
				(view as? NSTableCellView)?.imageView?.image = _deliveryIcon
			default:
				break
			}
		case let asLink as NVLink:
			(view as? NSTableCellView)?.textField?.stringValue = asLink.ID.uuidString
			(view as? NSTableCellView)?.imageView?.image = _linkIcon
		case let asBranch as NVBranch:
			(view as? NSTableCellView)?.textField?.stringValue = asBranch.ID.uuidString
			(view as? NSTableCellView)?.imageView?.image = _branchIcon
		case let asSwitch as NVSwitch:
			(view as? NSTableCellView)?.textField?.stringValue = asSwitch.ID.uuidString
			(view as? NSTableCellView)?.imageView?.image = _switchIcon
		default:
			(view as? NSTableCellView)?.textField?.stringValue = "ERROR"
		}
		
		return view
	}
}

extension OutlinerViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if nil == item {
			return Doc != nil ? 1 : 0 // main graph
		}
		
		switch item {
		case let asGraph as NVGraph:
			var count = 0
			count += asGraph.Graphs.count
			count += asGraph.Nodes.count
			count += asGraph.Links.count
			count += asGraph.Branches.count
			count += asGraph.Switches.count
			return count
		default:
			return 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if nil == item {
			return Doc!.Story.MainGraph! // valid at this point
		}
		
		switch item {
		case let asGraph as NVGraph:
			if index < asGraph.Graphs.count {
				return asGraph.Graphs[index]
			}
			var offset = asGraph.Graphs.count
			
			if index < (asGraph.Nodes.count + offset) {
				return asGraph.Nodes[index - offset]
			}
			offset += asGraph.Nodes.count
			
			if index < (asGraph.Links.count + offset) {
				return asGraph.Links[index - offset]
			}
			offset += asGraph.Links.count
			
			if index < (asGraph.Branches.count + offset) {
				return asGraph.Branches[index - offset]
			}
			offset += asGraph.Branches.count
			
			if index < (asGraph.Switches.count + offset) {
				return asGraph.Switches[index - offset]
			}
			offset += asGraph.Switches.count
			
			fatalError("Math is wrong.")
		default:
			fatalError("Oh dear.")
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case let asGraph as NVGraph:
			var count = 0
			count += asGraph.Graphs.count
			count += asGraph.Nodes.count
			count += asGraph.Links.count
			count += asGraph.Branches.count
			count += asGraph.Switches.count
			return count > 0
			
		default:
			return false
		}
	}
}
