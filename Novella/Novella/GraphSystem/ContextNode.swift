//
//  ContextNode.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class ContextNode: Node {
	// MARK: - - Initialization -
	init(node: NVContext, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvObject: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.Position)
		self.frame.size = widgetRect().size
		
		setLabelString(str: node.Name)
		setContentString(str: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("ContextNode::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onMove() {
		(Object as! NVContext).Position = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func flagColor() -> NSColor {
		return Settings.graph.nodes.contextColor
	}
	override func onNameChanged() {
		setLabelString(str: Object.Name)
	}
	override func onContentChanged() {
	}
	// MARK: Popover Functions
	override func _createPopover() {
		_editPopover = ContextPopover()
		_editPopover?.show(forView: self, at: .minY)
		(_editPopover as! ContextPopover).setup(node: self)
	}
}