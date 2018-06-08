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
		self.frame.origin = graphView.offsetFromEditorPosition(pos: node.EditorPosition)
		self.frame.size = widgetRect().size
		
		setLabelString(str: "D")
		
		// add shadow
		wantsLayer = true
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.black.cgColor
		self.layer?.shadowOffset = NSMakeSize(3, -1)
		self.layer?.shadowRadius = 5.0
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DeliveryLinkableView::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onTrashed() {
	}
	override func onMove() {
		(Linkable as! NVDelivery).EditorPosition = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func bgTopColor() -> NSColor {
		return Settings.graph.nodes.deliveryStartColor
	}
	override func bgBottomColor() -> NSColor {
		return Settings.graph.nodes.endColor
	}
}
