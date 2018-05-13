//
//  GraphViewController.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

enum SaveAlertResult {
	case save
	case dontsave
	case cancel
}

class GraphViewController: NSViewController {
	// MARK: - - Constants -
	fileprivate static let SCROLL_SIZE: CGFloat = 6000.0
	fileprivate static let MIN_ZOOM: CGFloat = 0.2
	fileprivate static let MAX_ZOOM: CGFloat = 4.0
	
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _graphTabView: NSTabView!
	
	// MARK: - - Variables -
	fileprivate var _story: NVStory = NVStory()
	fileprivate var _openedFile: URL?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	// MARK: - - Helpers -
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
		// remove all graph tabs
		for curr in _graphTabView.tabViewItems.reversed() {
			_graphTabView.removeTabViewItem(curr)
		}
		// create a new story
		_story = NVStory()
	}
	
	// MARK: - - UI Callbacks -
	@IBAction fileprivate func onOpenStory(_ sender: NSButton) {
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
		
		// remove all exiting graph tabs
		for curr in _graphTabView.tabViewItems.reversed() {
			_graphTabView.removeTabViewItem(curr)
		}
		
		// add a new graph tab for each subgraph of the story
		for curr in _story.Graphs {
			addNewTab(forGraph: curr)
		}
		
		// store file url for saving
		_openedFile = ofd.url!
	}
	@IBAction fileprivate func onCloseStory(_ sender: NSButton) {
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
	}
	@IBAction fileprivate func onSaveStory(_ sender: NSButton) {
		_ = saveStory()
	}
	@IBAction fileprivate func onNewStory(_ sender: NSButton) {
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
	fileprivate func getActiveGraph() -> GraphView? {
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
