//
//  GraphTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphTabViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet fileprivate weak var _scrollView: NSScrollView!
	
	// MARK: - - Variables -
	fileprivate static let GRAPH_SIZE: CGFloat = 6000.0
	fileprivate var _graphView: GraphView?
	//
	fileprivate var _story: NVStory?
	fileprivate var _graph: NVGraph?
	fileprivate var _delegate: GraphViewDelegate?
	
	// MARK: - - Properties -
	var Graph: GraphView? {
		get{ return _graphView }
	}
	
	// MARK: - - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// if setup was called pre-load...
		if _story != nil && _graph != nil && _delegate != nil {
			configure()
		}
	}
	
	fileprivate func configure() {
		_graphView = GraphView(graph: _graph!, story: _story!, frameRect: NSMakeRect(0.0, 0.0, GraphTabViewController.GRAPH_SIZE, GraphTabViewController.GRAPH_SIZE), visibleRect: NSRect.zero)
		_graphView?.Delegate = _delegate
		_scrollView.documentView = _graphView!
	}
	
	func setup(story: NVStory, graph: NVGraph, delegate: GraphViewDelegate) {
		_story = story
		_graph = graph
		_delegate = delegate
		
		// if the view has already loaded...
		if isViewLoaded {
			configure()
		}
	}
}
