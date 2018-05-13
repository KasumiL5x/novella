//
//  GraphViewCommands.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class MoveLinkableViewCmd: UndoableCommand {
	let _node: LinkableView
	let _from: CGPoint
	let _to: CGPoint
	
	init(node: LinkableView, from: CGPoint, to: CGPoint) {
		self._node = node
		self._from = from
		self._to = to
	}
	
	func execute() {
		_node.move(to: _to)
	}
	
	func unexecute() {
		_node.move(to: _from)
	}
}

class SetPinLinkDestinationCmd: UndoableCommand {
	let _pin: PinViewLink
	let _prevDest: NVLinkable?
	let _newDest: NVLinkable?
	
	init(pin: PinViewLink, destination: NVLinkable?) {
		self._pin = pin
		self._prevDest = _pin.getDestination()
		self._newDest = destination
	}
	
	func execute() {
		_pin.setDestination(dest: _newDest)
	}
	
	func unexecute() {
		_pin.setDestination(dest: _prevDest)
	}
}
