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
	// MARK: Gestures
	var _panGesture: NSPanGestureRecognizer?
	
	// MARK: - - Initialization -
	init(graph: NVGraph, story: NVStory, frameRect: NSRect) {
		self._nvGraph = graph
		self._nvStory = story
		self._bg = GraphBGView(frame: frameRect)
		//
		self._allLinkableViews = []
		//
		self._marquee = MarqueeView(frame: frameRect)
		//
		self._panGesture = nil
		
		super.init(frame: frameRect)
		
		self._panGesture = NSPanGestureRecognizer(target: self, action: #selector(GraphView.onPan))
		self._panGesture!.buttonMask = 0x1 // "primary button"
		self.addGestureRecognizer(self._panGesture!)
		
		rootFor(graph: _nvGraph)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphView::init(coder) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Gesture Callbacks
	@objc fileprivate func onPan(gesture: NSGestureRecognizer) {
		switch gesture.state {
		case .cancelled, .ended:
			if _marquee.InMarquee {
				// TODO: Select nodes based on marquee.
				_marquee.Marquee = NSRect.zero
				_marquee.InMarquee = false
			}
			break
			
		case .began:
			if !_marquee.InMarquee {
				_marquee.Origin = gesture.location(in: self)
				_marquee.InMarquee = true
			}
			break
			
		case .changed:
			if _marquee.InMarquee {
				let curr = gesture.location(in: self)
				_marquee.Marquee.origin = NSMakePoint(fmin(_marquee.Origin.x, curr.x), fmin(_marquee.Origin.y, curr.y))
				_marquee.Marquee.size = NSMakeSize(fabs(curr.x - _marquee.Origin.x), fabs(curr.y - _marquee.Origin.y))
			}
			break
			
		default:
			print("In unexpected pan state.")
			break
		}
	}
	
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
			
			switch curr {
			case is NVDialog:
				let node = DialogView(node: curr as! NVDialog)
				_allLinkableViews.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				break
			default:
				print("Not implemented node type \(curr).")
				break
			}
		}
	}
}
