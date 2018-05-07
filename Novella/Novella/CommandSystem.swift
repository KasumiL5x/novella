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

// MARK: CompoundCommand
class CompoundCommand: UndoableCommand {
	var _commands: [UndoableCommand]
	var _executeOnAdd: Bool
	
	init(executeOnAdd: Bool) {
		self._commands = []
		self._executeOnAdd = executeOnAdd
	}
	
	func add(cmd: UndoableCommand) {
		if _executeOnAdd {
			cmd.execute()
		}
		
		_commands.append(cmd)
	}
	
	func execute() {
		if !_executeOnAdd {
			return
		}
		
		for cmd in _commands {
			cmd.execute()
		}
	}
	
	func unexecute() {
		for cmd in _commands.reversed() {
			cmd.unexecute()
		}
	}
}

// MARK: UndoRedo
class UndoRedo {
	var _undoCommands: Stack<UndoableCommand>
	var _redoCommands: Stack<UndoableCommand>
	var _compoundUndo: CompoundCommand?
	
	init() {
		self._undoCommands = Stack<UndoableCommand>()
		self._redoCommands = Stack<UndoableCommand>()
		self._compoundUndo = nil
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
		// if a compound undo is in progress, add to it
		// but ignore adding compounds as we execute them upon closing compounds
		if _compoundUndo != nil && !(cmd is CompoundCommand) {
			_compoundUndo?.add(cmd: cmd)
		} else {
			cmd.execute()
			_undoCommands.push(cmd)
			_redoCommands.clear()
		}
	}
	
	func clear() {
		_undoCommands.clear()
		_redoCommands.clear()
	}
	
	func beginCompound(executeOnAdd: Bool) {
		if _compoundUndo != nil {
			fatalError("Attempted to begin a compound command without closing the previous one.")
		}
		
		_compoundUndo = CompoundCommand(executeOnAdd: executeOnAdd)
	}
	
	func endCompound() {
		if _compoundUndo == nil {
			fatalError("Attempted to end a compound command without starting it first.")
		}
		execute(cmd: _compoundUndo!)
		_compoundUndo = nil // warning: creates dangling CompoundCommand existing only in the stacks
	}
	
	func inCompound() -> Bool {
		return _compoundUndo != nil
	}
}

