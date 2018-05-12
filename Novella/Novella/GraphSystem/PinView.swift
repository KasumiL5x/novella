//
//  PinView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class PinView: NSView {
	// MARK: - - Variables -
	fileprivate var _nvBaseLink: NVBaseLink
	var _graphView: GraphView
	fileprivate var _owner: LinkableView
	
	// MARK: - - Initialization -
	init(link: NVBaseLink, graphView: GraphView, owner: LinkableView) {
		self._nvBaseLink = link
		self._graphView = graphView
		self._owner = owner
		
		super.init(frame: NSMakeRect(0.0, 0.0, 15.0, 15.0))
		
		// setup layers
		wantsLayer = true
		layer!.masksToBounds = false
	}
	required init?(coder decoder: NSCoder) {
		fatalError("PinView::init(coder) not implemented.")
	}
	
	// MARK: - - Properties -
	var BaseLink: NVBaseLink {
		get{ return _nvBaseLink }
	}
	
	// MARK: - - Functions -
	func redraw() {
		setNeedsDisplay(bounds)
	}
}
