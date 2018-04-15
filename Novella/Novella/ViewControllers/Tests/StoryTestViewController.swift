//
//  StoryTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 15/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class StoryTestViewController: NSViewController {
	var _story: Story? = nil
	
	@IBOutlet weak var browser: NSBrowser!
	@IBOutlet weak var statusLabel: NSTextField!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self._story = Story()
	}
	
	@IBAction func onAddGraph(_ sender: NSButton) {
		let idx = browser.selectionIndexPath
		if nil == idx {
			return
		}
		let item = browser.item(at: idx!)
		
		let name = NSUUID().uuidString
		if let graph = item as? FlowGraph {
			do{ try graph.makeGraph(name: name) } catch {
				statusLabel.stringValue = "Tried to add FG but name was in use (\(name) to \(graph._name))"
			}
		}
		
		browser.loadColumnZero()
	}
	
	@IBAction func onRemoveGraph(_ sender: NSButton) {
//		let name = NSUUID().uuidString
	}
}

extension StoryTestViewController: NSBrowserDelegate {
	func rootItem(for browser: NSBrowser) -> Any? {
		return _story
	}
	
	func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
		if let story = item as? Story {
			return story._graphs.count
		}
		if let graph = item as? FlowGraph {
			return graph._graphs.count
		}
		return 0
	}
	
	func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
		if let story = item as? Story {
			return story._graphs[index]
		}
		if let graph = item as? FlowGraph {
			return graph._graphs[index]
		}
		return []
	}
	
	func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
		if let story = item as? Story {
			return story._graphs.count == 0
		}
		if let graph = item as? FlowGraph {
			return graph._graphs.count == 0
		}
		return false
	}
	
	func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
		if let story = item as? Story {
			return "story"
		}
		if let graph = item as? FlowGraph {
			return graph._name
		}
		return "error"
	}
}
