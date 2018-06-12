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
