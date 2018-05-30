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
	// MARK: - - Variables -
	fileprivate let _nameLabel: NSTextField
	
	// MARK: - - Initialization -
	init(node: NVGraph, graphView: GraphView) {
		self._nameLabel = NSTextField(labelWithString: "G")
		self._nameLabel.tag = LinkableView.HIT_IGNORE_TAG
		
		let rect = NSMakeRect(node.EditorPosition.x, node.EditorPosition.y, 1.0, 1.0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		self.frame.size = widgetRect().size
		
		// set up name label
		self._nameLabel.textColor = NSColor.fromHex("#f2f2f2")
		self._nameLabel.font = NSFont.systemFont(ofSize: 42.0, weight: .ultraLight)
		self._nameLabel.sizeToFit()
		self._nameLabel.frame.origin = NSMakePoint(self.frame.width/2 - self._nameLabel.frame.width/2, self.frame.height/2 - self._nameLabel.frame.height/2)
		self.addSubview(self._nameLabel)
		
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
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onTrashed() {
	}
	override func widgetRect() -> NSRect {
		return NSMakeRect(0.0, 0.0, 64.0, 64.0)
	}
	override func onMove() {
		(Linkable as? NVGraph)?.EditorPosition = frame.origin
	}
	override func bgTopColor() -> NSColor {
		return Settings.graph.nodes.graphStartColor
	}
	override func bgBottomColor() -> NSColor {
		return Settings.graph.nodes.endColor
	}
}
