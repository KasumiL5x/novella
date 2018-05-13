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
	fileprivate let _node: LinkableView
	fileprivate let _from: CGPoint
	fileprivate let _to: CGPoint
	
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
	fileprivate let _pin: PinViewLink
	fileprivate let _prevDest: NVLinkable?
	fileprivate let _newDest: NVLinkable?
	
	init(pin: PinViewLink, destination: NVLinkable?) {
		self._pin = pin
		self._prevDest = pin.getDestination()
		self._newDest = destination
	}
	
	func execute() {
		_pin.setDestination(dest: _newDest)
	}
	
	func unexecute() {
		_pin.setDestination(dest: _prevDest)
	}
}

class SetPinBranchDestinationCmd: UndoableCommand {
	fileprivate let _pin: PinViewBranch
	fileprivate let _prevDest: NVLinkable?
	fileprivate let _newDest: NVLinkable?
	fileprivate let _forTrue: Bool
	
	init(pin: PinViewBranch, destination: NVLinkable?, forTrue: Bool) {
		self._pin = pin
		self._prevDest = forTrue ? pin.getTrueDestination() : pin.getFalseDestination()
		self._newDest = destination
		self._forTrue = forTrue
	}
	
	func execute() {
		if _forTrue {
			_pin.setTrueDestination(dest: _newDest)
		} else {
			_pin.setFalseDestination(dest: _newDest)
		}
	}
	
	func unexecute() {
		if _forTrue {
			_pin.setTrueDestination(dest: _prevDest)
		} else {
			_pin.setFalseDestination(dest: _prevDest)
		}
	}
}
