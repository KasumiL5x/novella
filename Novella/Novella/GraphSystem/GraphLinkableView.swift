//
//  GraphLinkableView.swift
//  Novella
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphLinkableView: LinkableView {
	// MARK: - - Initialization -
	init(node: NVGraph, graphView: GraphView) {
		let rect = NSMakeRect(0, 0, 0, 0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		
		// add shadow
		wantsLayer = true
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.black.cgColor
		self.layer?.shadowOffset = NSMakeSize(3, -1)
		self.layer?.shadowRadius = 5.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphLinkableModel::init(coder) not implemented.")
	}
}
