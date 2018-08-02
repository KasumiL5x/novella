//
//  DeliveryNode.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DeliveryNode: Node {
	// MARK: - Initialization -
	init(node: NVDelivery, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvObject: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.Position)
		self.frame.size = widgetRect().size
		
		setLabelString(str: node.Name)
		setContentString(str: node.Content)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DeliveryNode::init(coder:) not implemented.")
	}
	
	// MARK: - Functions -
	// MARK: Virtual Functions
	override func onMove() {
		(Object as! NVDelivery).Position = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func flagColor() -> NSColor {
		return Settings.graph.nodes.deliveryColor
	}
	override func onNameChanged() {
		setLabelString(str: Object.Name)
	}
	override func onContentChanged() {
		setContentString(str: (Object as! NVDelivery).Content)
	}
	// MARK: Popover Functions
	override func _createPopover() {
		_editPopover = DeliveryPopover()
		_editPopover?.show(forView: self, at: .minY)
		(_editPopover as! DeliveryPopover).setup(node: self)
	}
}
