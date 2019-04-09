//
//  SequencePopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 09/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class SequencePopoverViewController: NSViewController {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _condition: NSComboBox!
	@IBOutlet weak private var _entryFunction: NSComboBox!
	@IBOutlet weak private var _exitFunction: NSComboBox!
	@IBOutlet weak private var _activations: NSTextField!
	@IBOutlet weak private var _topmost: NSButton!
	@IBOutlet weak private var _keepAlive: NSButton!
	@IBOutlet weak private var _entry: NSButton!
	@IBOutlet weak private var _parallel: NSButton!
	@IBOutlet weak private var _attributesTable: AttributeTableView!
	//
	@IBOutlet private var _dc: NSDictionaryController!
	
	
	weak private var _doc: Document?
	weak private var _sequence: CanvasSequence?
	
	func setup(sequence: CanvasSequence, doc: Document) {
		self._sequence = sequence
		self._doc = doc
		
		_dc.content = sequence.Sequence.Attributes
		
		_attributesTable.onAdd = {
			let kvp = self._dc.newObject()
			kvp.key = NVUtil.randomString(length: 10)
			kvp.value = "value"
			self._dc.addObject(kvp)
		}
		_attributesTable.onDelete = { (key) in
			self._dc.remove(key)
		}
		
		setupLabel(sequence: sequence)
		setupCondition(sequence: sequence, doc: doc)
		setupEntryFunction(sequence: sequence, doc: doc)
		setupExitFunction(sequence: sequence, doc: doc)
		setupActivations(sequence: sequence)
		setupTopmost(sequence: sequence)
		setupKeepAlive(sequence: sequence)
		setupEntry(sequence: sequence)
		setupParallel(sequence: sequence)
	}
	
	private func setupLabel(sequence: CanvasSequence) {
		_label.stringValue = sequence.Sequence.Label
	}
	
	private func setupCondition(sequence: CanvasSequence, doc: Document) {
		_condition.removeAllItems()
		doc.Story.Conditions.forEach{ _condition.addItem(withObjectValue: $0.Label) }
		
		let idx = _condition.indexOfItem(withObjectValue: sequence.Sequence.PreCondition?.Label ?? "")
		if idx != NSNotFound {
			_condition.selectItem(at: idx)
		} else {
			_condition.stringValue = ""
		}
	}
	
	private func setupEntryFunction(sequence: CanvasSequence, doc: Document) {
		_entryFunction.removeAllItems()
		doc.Story.Functions.forEach{ _entryFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _entryFunction.indexOfItem(withObjectValue: sequence.Sequence.EntryFunction?.Label ?? "")
		if idx != NSNotFound {
			_entryFunction.selectItem(at: idx)
		} else {
			_entryFunction.stringValue = ""
		}
	}
	
	private func setupExitFunction(sequence: CanvasSequence, doc: Document) {
		_exitFunction.removeAllItems()
		doc.Story.Functions.forEach{ _exitFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _exitFunction.indexOfItem(withObjectValue: sequence.Sequence.ExitFunction?.Label ?? "")
		if idx != NSNotFound {
			_exitFunction.selectItem(at: idx)
		} else {
			_exitFunction.stringValue = ""
		}
	}
	
	private func setupActivations(sequence: CanvasSequence) {
		_activations.stringValue = "\(sequence.Sequence.MaxActivations)"
	}
	
	private func setupTopmost(sequence: CanvasSequence) {
		_topmost.state = sequence.Sequence.Topmost ? .on : .off
	}
	
	private func setupKeepAlive(sequence: CanvasSequence) {
		_keepAlive.state = sequence.Sequence.KeepAlive ? .on : .off
	}
	
	private func setupEntry(sequence: CanvasSequence) {
		_entry.state = sequence.Sequence.Parent?.Entry == sequence.Sequence ? .on : .off
	}
	
	private func setupParallel(sequence: CanvasSequence) {
		_parallel.state = sequence.Sequence.Parallel ? .on : .off
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		_sequence?.Sequence.Label = sender.stringValue
	}
	
	@IBAction func conditionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let sequence = _sequence else {
			return
		}
		
		let label = sender.stringValue
		guard let condition = doc.Story.Conditions.first(where: {$0.Label == label}) else {
			print("Could not find Condition: \(label). Setting to nil.")
			sender.stringValue = ""
			sequence.Sequence.PreCondition = nil
			return
		}
		sequence.Sequence.PreCondition = condition
	}
	
	@IBAction func entryFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let sequence = _sequence else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			sequence.Sequence.EntryFunction = nil
			return
		}
		sequence.Sequence.EntryFunction = function
	}
	
	@IBAction func exitFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let sequence = _sequence else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			sequence.Sequence.ExitFunction = nil
			return
		}
		sequence.Sequence.ExitFunction = function
	}
	
	@IBAction func activationsDidChange(_ sender: NSTextField) {
		_sequence?.Sequence.MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func topmostDidChange(_ sender: NSButton) {
		_sequence?.Sequence.Topmost = sender.state == .on
	}
	
	@IBAction func keepAliveDidChange(_ sender: NSButton) {
		_sequence?.Sequence.KeepAlive = sender.state == .on
	}
	
	@IBAction func entryDidChange(_ sender: NSButton) {
		_sequence?.Sequence.Parent?.Entry = (sender.state == .on) ? _sequence?.Sequence : nil
		_sequence?.reloadData() // refresh entry icon
	}
	
	@IBAction func parallelDidChange(_ sender: NSButton) {
		_sequence?.Sequence.Parallel = sender.state == .on
		_sequence?.reloadData() // refresh parallel icon
	}
}
