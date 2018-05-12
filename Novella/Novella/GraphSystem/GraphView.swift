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
	// MARK: Selection
	var _marquee: MarqueeView
	
	// MARK: - - Initialization -
	init(graph: NVGraph, story: NVStory, frameRect: NSRect) {
		self._nvGraph = graph
		self._nvStory = story
		self._bg = GraphBGView(frame: frameRect)
		//
		self._allLinkableViews = []
		//
		self._marquee = MarqueeView(frame: frameRect)
		
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
		// add marquee view (must be last; others add after it)
		self.addSubview(_marquee)
		
		// clear existing linkable views
		_allLinkableViews = []
		
		// load all views
		for curr in graph.Nodes {
			print(curr)
			let linkableView = LinkableView(frameRect: NSMakeRect(100.0, 100.0, 100.0, 100.0), nvLinkable: curr)
			_allLinkableViews.append(linkableView)
			self.addSubview(linkableView, positioned: .below, relativeTo: _marquee)
		}
	}
	
	// MARK: Mouse Events
	override func mouseDown(with event: NSEvent) {
		// begin marquee
		_marquee.Origin = self.convert(event.locationInWindow, from: nil)
		_marquee.InMarquee = true
	}
	override func mouseDragged(with event: NSEvent) {
		if _marquee.InMarquee {
			let curr = self.convert(event.locationInWindow, from: nil)
			_marquee.Marquee.origin = NSMakePoint(fmin(_marquee.Origin.x, curr.x), fmin(_marquee.Origin.y, curr.y))
			_marquee.Marquee.size = NSMakeSize(fabs(curr.x - _marquee.Origin.x), fabs(curr.y - _marquee.Origin.y))
		}
	}
	override func mouseUp(with event: NSEvent) {
		if _marquee.InMarquee {
			// TODO: Select nodes based on marquee.
			_marquee.Marquee = NSRect.zero
			_marquee.InMarquee = false
		}
	}
}
