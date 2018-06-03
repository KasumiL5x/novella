//
//  GraphViewCommands.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class SelectNodesCmd: UndoableCommand {
	private let _selection: [LinkableView]
	private let _handler: SelectionHandler
	
	init(selection: [LinkableView], handler: SelectionHandler) {
		self._selection = selection
		self._handler = handler
	}
	
	func execute() {
		_handler.select(_selection, append: true)
	}
	
	func unexecute() {
		_handler.deselect(_selection)
	}
}
class ReplacedSelectedNodesCmd: UndoableCommand {
	private let _selection: [LinkableView]
	private let _oldSelection: [LinkableView]
	private let _handler: SelectionHandler
	
	init(selection: [LinkableView], handler: SelectionHandler) {
		self._selection = selection
		self._oldSelection = handler.Selection.map({$0}) // arrays have value copy in swift
		self._handler = handler
	}
	
	func execute() {
		_handler.select(_selection, append: false)
	}
	
	func unexecute() {
		_handler.select(_oldSelection, append: false)
	}
}
class DeselectNodesCmd: UndoableCommand {
	private let _selection: [LinkableView]
	private let _handler: SelectionHandler
	
	init(selection: [LinkableView], handler: SelectionHandler) {
		self._selection = selection
		self._handler = handler
	}
	
	func execute() {
		_handler.deselect(_selection)
	}
	
	func unexecute() {
		_handler.select(_selection, append: true)
	}
}

class MoveLinkableViewCmd: UndoableCommand {
	private let _node: LinkableView
	private let _from: CGPoint
	private let _to: CGPoint
	
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
	private let _pin: PinViewLink
	private let _prevDest: NVLinkable?
	private let _newDest: NVLinkable?
	
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
	private let _pin: PinViewBranch
	private let _prevDest: NVLinkable?
	private let _newDest: NVLinkable?
	private let _forTrue: Bool
	
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
