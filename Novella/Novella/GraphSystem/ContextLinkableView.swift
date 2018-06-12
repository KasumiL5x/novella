//
//  ContextLinkableView.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class ContextLinkableView: LinkableView {
	// MARK: - - Initialization -
	init(node: NVContext, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.EditorPosition)
		self.frame.size = widgetRect().size
		
		setLabelString(str: "C")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("ContextLinkableView::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onTrashed() {
	}
	override func onMove() {
		(Linkable as! NVContext).EditorPosition = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func bgTopColor() -> NSColor {
		return Settings.graph.nodes.contextStartColor
	}
	override func bgBottomColor() -> NSColor {
		return Settings.graph.nodes.endColor
	}
}
