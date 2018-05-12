//
//  GraphViewController.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphViewController: NSViewController {
	// MARK: - - Constants -
	fileprivate static let SCROLL_SIZE: CGFloat = 6000.0
	fileprivate static let MIN_ZOOM: CGFloat = 0.2
	fileprivate static let MAX_ZOOM: CGFloat = 4.0
	
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _graphTabView: NSTabView!
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory = NVStory()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - - Helpers -
	fileprivate func alertCancelOK(message: String, info: String) -> Bool {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = info
		alert.alertStyle = .warning
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "OK")
		return alert.runModal() != .alertFirstButtonReturn // true for OK, false for Cancel
	}
	fileprivate func alertError(message: String, info: String) {
		let alert = NSAlert()
		alert.messageText = message
		alert.informativeText = info
		alert.alertStyle = .critical
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
	fileprivate func createEmptyStory() {
		// remove all graph tabs
		for curr in _graphTabView.tabViewItems.reversed() {
			_graphTabView.removeTabViewItem(curr)
		}
		// create a new story
		_story = NVStory()
	}
	
	// MARK: - - UI Callbacks -
	@IBAction fileprivate func onOpenStory(_ sender: NSButton) {
		if !alertCancelOK(message: "Open Story?", info: "This will replace the current story.") {
			return
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
		
		// remove all exiting graph tabs
		for curr in _graphTabView.tabViewItems.reversed() {
			_graphTabView.removeTabViewItem(curr)
		}
		
		// add a new graph tab for each subgraph of the story
		for curr in _story.Graphs {
			addNewTab(forGraph: curr)
		}
	}
	@IBAction fileprivate func onCloseStory(_ sender: NSButton) {
		// TODO: Handle unsaved stories.
		if !alertCancelOK(message: "Close Story?", info: "Closing the story will lose any unsaved progress?") {
			return
		}
		createEmptyStory()
	}
	@IBAction fileprivate func onSaveStory(_ sender: NSButton) {
		fatalError("Not yet implemented.")
	}
	@IBAction fileprivate func onNewStory(_ sender: NSButton) {
		if !alertCancelOK(message: "Create new Story?", info: "This will replace the current story.") {
			return
		}
		createEmptyStory()
	}
	@IBAction fileprivate func onAddGraph(_ sender: NSButton) {
		let graph = _story.makeGraph(name: "New Graph")
		addNewTab(forGraph: graph)
	}
	@IBAction func onUndo(_ sender: NSButton) {
		getActiveGraph()?.undo(levels: 1)
	}
	@IBAction func onRedo(_ sender: NSButton) {
		getActiveGraph()?.redo(levels: 1)
	}
	
	// MARK: - - Private Functions -
	func getActiveGraph() -> GraphView? {
		// NOTE: This is fugly as hell but it is functional based on the setup I have.  If that changes, this will have to also.
		let graph = ((_graphTabView.selectedTabViewItem?.view?.subviews[0] as? NSScrollView)?.documentView as? GraphView)
		return graph
	}
	
	
	// MARK: IDK
	fileprivate func addNewTab(forGraph: NVGraph) {
		let tabViewItem = NSTabViewItem()
		tabViewItem.label = forGraph.Name
		let view = tabViewItem.view!
		
		let scrollView = NSScrollView()
		scrollView.allowsMagnification = true
		scrollView.minMagnification = GraphViewController.MIN_ZOOM
		scrollView.maxMagnification = GraphViewController.MAX_ZOOM
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
		
		let graphView = GraphView(graph: forGraph,story: _story, frameRect: NSMakeRect(0.0, 0.0, GraphViewController.SCROLL_SIZE, GraphViewController.SCROLL_SIZE))
		scrollView.documentView = graphView
		
		_graphTabView.addTabViewItem(tabViewItem)
	}
}
