//
//  ViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class MainViewController: NSViewController {
	// MARK: - Variables -
	private var _appeared: Bool = false
	private var _document: NovellaDocument!
	private var _graphViewVC: GraphEditorViewController?
	
	// MARK: - Outlets -
	@IBOutlet private weak var _splitView: NSSplitView!
	@IBOutlet private weak var _allGraphsOutline: AllGraphsOutlineView!
	@IBOutlet private weak var _selectedGraphOutline: SelectedGraphOutlineView!
	@IBOutlet private weak var _selectedGraphName: NSTextField!
	
	// MARK: - Delegates & Data Sources -
	private var _storyDelegate: StoryDelegate?
	private var _allGraphsDelegate: AllGraphsDelegate?
	private var _selectedGraphDelegate: SelectedGraphDelegate?
	
	// MARK: - Properties -
	var Document: NovellaDocument {
		get{ return _document }
	}
	var Undo: UndoRedo? {
		get{ return _document?.Undo }
	}
	
	// MARK: - Initialization -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// delegates and data sources
		_storyDelegate = StoryDelegate(mvc: self)
		_allGraphsDelegate = AllGraphsDelegate(mvc: self)
		_selectedGraphDelegate = SelectedGraphDelegate(mvc: self)
		
		// split view
		_splitView.delegate = self
		
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
			
			// configure graph VC with an existing graph or make a new one
			let graph: NVGraph
			if let first = _document.Manager.Story.Graphs.first {
				graph = first
			} else {
				graph = _document.Manager.makeGraph(name: "main")
				_document.Manager.Story.add(graph: graph)
			}
			_graphViewVC?.setup(doc: _document, graph: graph, delegate: self)
			setSelectedGraph(graph: graph, allowReloadSelf: true)
			
			reloadAllGraphs()
			reloadSelectedGraph()
			
			_appeared = true
		}
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == NSStoryboardSegue.Identifier(rawValue: "GraphSegue") {
			_graphViewVC = segue.destinationController as? GraphEditorViewController
		}
		
		if segue.identifier == NSStoryboardSegue.Identifier(rawValue: "OutlinerFilterSegue") {
			let vc = segue.destinationController as? OutlinerFilterViewController
			vc?.contextChanged = { (state) in
				self._selectedGraphDelegate?._showContexts = state
				self.reloadSelectedGraph()
			}
			vc?.deliveriesChanged = { (state) in
				self._selectedGraphDelegate?._showDeliveries = state
				self.reloadSelectedGraph()
			}
			vc?.dialogsChanged = { (state) in
				self._selectedGraphDelegate?._showDialogs = state
				self.reloadSelectedGraph()
			}
			vc?.linksChanged = { (state) in
				self._selectedGraphDelegate?._showLinks = state
				self.reloadSelectedGraph()
			}
			vc?.subgraphsChanged = { (state) in
				self._selectedGraphDelegate?._showSubgraphs = state
				self.reloadSelectedGraph()
			}
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
		getActiveGraph()?.redrawAll()
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
	}
	@IBAction func onOutlinerFilterChanged(_ sender: NSSearchField) {
		_selectedGraphDelegate?._filter = sender.stringValue
		reloadSelectedGraph()
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
	
	func setSelectedGraph(graph: NVGraph?, allowReloadSelf: Bool=false) {
		if !allowReloadSelf && getActiveGraph()?.NovellaGraph == graph {
			return
		}
		
		_selectedGraphDelegate?.Graph = graph
		reloadSelectedGraph()
		
		// handle opening of graph view
		if let graph = graph {
			getActiveGraph()?.rootFor(graph: graph)
			zoomGraph()
		}
	}
}

// MARK: - Helper Functions -
extension MainViewController {
	func addGraph(parent: NVGraph?) {
		let graph = _document.Manager.makeGraph(name: NSUUID().uuidString)
		if parent == nil {
			_document.Manager.Story.add(graph: graph)
		} else {
			parent!.add(graph: graph)
		}
		
		getActiveGraph()?.rootFor(graph: graph)
		zoomGraph()
		
		reloadAllGraphs()
		_allGraphsOutline.selectRowIndexes([_allGraphsOutline.row(forItem: graph)], byExtendingSelection: false)
		reloadSelectedGraph()
	}
}

// MARK: - - Tabs -
extension MainViewController {
	func getActiveGraph() -> GraphView? {
		return _graphViewVC?.Graph
	}
	
	func zoomGraph() {
		if let graphVC = _graphViewVC {
			if !graphVC.zoomSelected() {
				_ = graphVC.zoomAll()
			}
		}
	}
	
	func zoomGraph(percent: CGFloat) { // 0...1+
		if let graphVC = _graphViewVC {
			graphVC.zoom(to: percent)
		}
	}
	
	func centerActiveGraph() {
		_graphViewVC?.centerView(animated: true)
	}
	
	func undo() {
		getActiveGraph()?.undo()
	}
	
	func redo() {
		getActiveGraph()?.redo()
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
	func onSelectionChanged(graphView: GraphView, selection: [Node]) {
	}
}
