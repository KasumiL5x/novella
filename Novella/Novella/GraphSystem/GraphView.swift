//
//  GraphView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphView: NSView {
	// MARK: - - Variables -
	fileprivate let _nvGraph: NVGraph
	fileprivate let _nvStory: NVStory
	fileprivate let _bg: GraphBGView
	//
	fileprivate var _allLinkableViews: [LinkableView]
	
	// MARK: - - Initialization -
	init(graph: NVGraph, story: NVStory, frameRect: NSRect) {
		self._nvGraph = graph
		self._nvStory = story
		self._bg = GraphBGView(frame: frameRect)
		//
		self._allLinkableViews = []
		
		super.init(frame: frameRect)
		
		rootFor(graph: _nvGraph)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphView::init(coder) not implemented.")
	}
	
	// MARK: - - Functions -
	fileprivate func rootFor(graph: NVGraph) {
		// remove existing views
		self.subviews.removeAll()
		
		// add background
		self.addSubview(_bg)
		
		// clear existing linkable views
		_allLinkableViews = []
		
		// load all views
		for curr in graph.Nodes {
			print(curr)
			let linkableView = LinkableView(frameRect: NSMakeRect(100.0, 100.0, 100.0, 100.0), nvLinkable: curr)
			_allLinkableViews.append(linkableView)
			addSubview(linkableView)
		}
	}
}
