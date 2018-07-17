//
//  DialogNode.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DialogNode: Node {
	// MARK: - - Initialization -
	init(node: NVDialog, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvObject: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.Position)
		self.frame.size = widgetRect().size
		
		setLabelString(str: node.Name)
		setContentString(str: node.Content)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DialogNode::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onMove() {
		(Object as! NVDialog).Position = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func flagColor() -> NSColor {
		return Settings.graph.nodes.dialogColor
	}
	override func onNameChanged() {
		setLabelString(str: Object.Name)
	}
	override func onContentChanged() {
		setContentString(str: (Object as! NVDialog).Content)
	}
	// MARK: Popover Functions
	override func _createPopover() {
		_editPopover = DialogPopover()
		_editPopover?.show(forView: self, at: .minY)
		(_editPopover as! DialogPopover).setup(node: self, manager: _graphView.Manager)
	}
}
