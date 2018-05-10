//
//  NodeGraphCommands.swift
//  Novella
//
//  Created by Daniel Green on 06/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation
import NovellaModel

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

class SetLinkDestinationCmd: UndoableCommand {
	let _pin: LinkPinView
	let _prevDest: NVLinkable?
	let _newDest: NVLinkable?
	
	init(pin: LinkPinView, destination: NVLinkable?) {
		self._pin = pin
		self._prevDest = (_pin._nvBaseLink as! NVLink).Transfer.Destination
		self._newDest = destination
	}
	
	func execute() {
		(_pin._nvBaseLink as! NVLink).Transfer.Destination = _newDest
	}
	
	func unexecute() {
		(_pin._nvBaseLink as! NVLink).Transfer.Destination = _prevDest
	}
}
