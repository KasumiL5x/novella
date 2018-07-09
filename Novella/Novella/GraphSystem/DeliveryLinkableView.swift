//
//  DeliveryLinkableView.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DeliveryLinkableView: LinkableView {
	// MARK: - - Initialization -
	init(node: NVDelivery, graphView: GraphView) {
		let rect = NSMakeRect(0.0, 0.0, 1.0, 1.0)
		super.init(frameRect: rect, nvLinkable: node, graphView: graphView)
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.Position)
		self.frame.size = widgetRect().size
		
		setLabelString(str: node.Name)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DeliveryLinkableView::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onMove() {
		(Linkable as! NVDelivery).Position = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func flagColor() -> NSColor {
		return Settings.graph.nodes.deliveryColor
	}
	override func onNameChanged() {
		setLabelString(str: Linkable.Name)
	}
	override func onContentChanged() {
		setLabelString(str: (Linkable as! NVDelivery).Content)
	}
	// MARK: Popover Functions
	override func _createPopover() {
		_editPopover = DeliveryPopover()
		_editPopover?.show(forView: self, at: .minY)
		(_editPopover as! DeliveryPopover).setup(node: self)
	}
}
