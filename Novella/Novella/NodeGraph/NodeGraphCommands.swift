//
//  NodeGraphCommands.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class MoveLinkableWidgetCmd: UndoableCommand {
	let _widget: LinkableWidget
	let _from: CGPoint
	let _to: CGPoint
	
	init(widget: LinkableWidget, from: CGPoint, to: CGPoint) {
		self._widget = widget
		self._from = from
		self._to = to
	}
	
	func execute() {
		_widget.move(to: _to)
	}
	
	func unexecute() {
		_widget.move(to: _from)
	}
}
