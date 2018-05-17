//
//  MVC+StoryBrowserDataSource.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class StoryBrowserDataSource: NSObject, NSOutlineViewDataSource {
	fileprivate let _mvc: MainViewController
	fileprivate let _browserTopLevel: [String]
	
	init(mvc: MainViewController) {
		self._mvc = mvc
		self._browserTopLevel = [
			"Graphs",
			"Variables"
		]
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
				return _mvc.Story.Graphs.count
			}
			if asString == _browserTopLevel[1] {
				return _mvc.Story.Folders.count
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
				return _mvc.Story.Graphs[index]
			}
			if asString == _browserTopLevel[1] {
				return _mvc.Story.Folders[index]
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
				return _mvc.Story.Graphs.count > 0
			}
			if asString == _browserTopLevel[1] {
				return _mvc.Story.Folders.count > 0
			}
		}
		
		return false
	}
}
