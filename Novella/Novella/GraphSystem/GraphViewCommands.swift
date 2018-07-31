//
//  GraphViewCommands.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class MoveNodeCmd: UndoableCommand {
	private let _node: Node
	private let _from: CGPoint
	private let _to: CGPoint
	
	init(node: Node, from: CGPoint, to: CGPoint) {
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

class SetTransferDestinationCmd: UndoableCommand {
	private let _transfer: Transfer
	private let _prevDest: NVObject?
	private let _newDest: NVObject?
	
	init(transfer: Transfer, dest: NVObject?) {
		self._transfer = transfer
		self._prevDest = transfer.Destination
		self._newDest = dest
	}
	
	func execute() {
		_transfer.Destination = _newDest
	}
	
	func unexecute() {
		_transfer.Destination = _prevDest
	}
}
