//
//  DialogView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class DialogLinkableView: LinkableView {
	// MARK: - - Initialization -
	init(node: NVDialog, graphView: GraphView) {
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
		fatalError("DialogLinkableView::init(coder:) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Virtual Functions
	override func onTrashed() {
	}
	override func onMove() {
		(Linkable as! NVDialog).EditorPosition = _graphView.offsetToEditorPosition(pos: frame.origin)
	}
	override func bgTopColor() -> NSColor {
		return Settings.graph.nodes.dialogStartColor
	}
	override func bgBottomColor() -> NSColor {
		return Settings.graph.nodes.endColor
	}
}
