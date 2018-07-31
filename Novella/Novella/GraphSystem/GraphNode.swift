//
//  GraphNode.swift
//  Novella
//
//  Created by Daniel Green on 14/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphNode: Node {
	// MARK: - - Initialization -
	init(node: NVGraph, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvObject: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.Position)
		self.frame.size = widgetRect().size
		
		setLabelString(str: node.Name)
		setContentString(str: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphNode::init(coder) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onMove() {
		(Object as? NVGraph)?.Position = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func flagColor() -> NSColor {
		return Settings.graph.nodes.graphColor
	}
	override func onNameChanged() {
		setLabelString(str: Object.Name)
	}
	override func onContentChanged() {
	}
	// MARK: Popover Functions
	override func _createPopover() {
	}
}