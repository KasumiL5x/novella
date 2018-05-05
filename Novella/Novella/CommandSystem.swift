//
//  CommandSystem.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

// MARK: Stack
public struct Stack<T> {
	fileprivate var array = [T]()
	
	public var isEmpty: Bool {
		return array.isEmpty
	}
	
	public var count: Int {
		return array.count
	}
	
	public mutating func push(_ element: T) {
		array.append(element)
	}
	
	public mutating func pop() -> T? {
		return array.popLast()
	}
	
	public var top: T? {
		return array.last
	}
	
	public mutating func clear() {
		array = [T]()
	}
}

extension Stack: Sequence {
	public func makeIterator() -> AnyIterator<T> {
		var curr = self
		return AnyIterator {
			return curr.pop()
		}
	}
}


// MARK: Undoable/Command
protocol Command {
	func execute()
}
protocol UndoableCommand: Command {
	func unexecute()
}

// MARK: CommandList
class CommandList {
	var _undoableCommands: Stack<UndoableCommand>
	
	init() {
		self._undoableCommands = Stack<UndoableCommand>()
	}
	
	func execute(cmd: Command) {
		cmd.execute()
		if let undoable = cmd as? UndoableCommand {
			_undoableCommands.push(undoable)
		}
	}
	
	func undo() {
		if let top = _undoableCommands.pop() {
			top.unexecute()
		}
	}
}

// MARK: UndoRedo
class UndoRedo {
	var _undoCommands: Stack<UndoableCommand>
	var _redoCommands: Stack<UndoableCommand>
	
	init() {
		self._undoCommands = Stack<UndoableCommand>()
		self._redoCommands = Stack<UndoableCommand>()
	}
	
	func undo(levels: Int) {
		for _ in 1...levels {
			if let cmd = _undoCommands.pop() {
				cmd.unexecute()
				_redoCommands.push(cmd)
			}
		}
	}
	
	func redo(levels: Int) {
		for _ in 1...levels {
			if let cmd = _redoCommands.pop() {
				cmd.execute()
				_undoCommands.push(cmd)
			}
		}
	}
	
	func execute(cmd: UndoableCommand) {
		cmd.execute()
		_undoCommands.push(cmd)
		_redoCommands.clear()
	}
	
	
}

