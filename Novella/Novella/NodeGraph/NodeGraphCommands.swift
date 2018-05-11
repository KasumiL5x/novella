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
		self._prevDest = _pin.getDest()
		self._newDest = destination
	}
	
	func execute() {
		_pin.setDest(dest: _newDest)
	}
	
	func unexecute() {
		_pin.setDest(dest: _prevDest)
	}
}
class SetBranchDestinationCmd: UndoableCommand {
	let _pin: BranchPinView
	let _prevDest: NVLinkable?
	let _newDest: NVLinkable?
	let _true: Bool
	
	init(pin: BranchPinView, destination: NVLinkable?, trueFalse: Bool) {
		self._pin = pin
		self._prevDest = trueFalse ? _pin.getTrueDest() : _pin.getFalseDest()
		self._newDest = destination
		self._true = trueFalse
	}
	
	func execute() {
		if _true {
			_pin.setTrueDest(dest: _newDest)
		} else {
			_pin.setFalseDest(dest: _newDest)
		}
	}
	
	func unexecute() {
		if _true {
			_pin.setTrueDest(dest: _prevDest)
		} else {
			_pin.setFalseDest(dest: _prevDest)
		}
	}
}
