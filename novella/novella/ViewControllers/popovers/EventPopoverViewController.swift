//
//  EventPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 09/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class EventPopoverViewController: NSViewController {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _condition: NSComboBox!
	@IBOutlet weak private var _entryFunction: NSComboBox!
	@IBOutlet weak private var _doFunction: NSComboBox!
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
	weak private var _event: CanvasEvent?
	
	func setup(event: CanvasEvent, doc: Document) {
		self._event = event
		self._doc = doc
		
		_dc.content = event.nvEvent().Attributes
		
		_attributesTable.onAdd = {
			let kvp = self._dc.newObject()
			kvp.key = NVUtil.randomString(length: 10)
			kvp.value = "value"
			self._dc.addObject(kvp)
		}
		_attributesTable.onDelete = { (key) in
			self._dc.remove(key)
		}
		
		setupLabel(event: event)
		setupCondition(event: event, doc: doc)
		setupEntryFunction(event: event, doc: doc)
		setupDoFunction(event: event, doc: doc)
		setupExitFunction(event: event, doc: doc)
		setupActivations(event: event)
		setupTopmost(event: event)
		setupKeepAlive(event: event)
		setupEntry(event: event)
		setupParallel(event: event)
	}
	
	private func setupLabel(event: CanvasEvent) {
		_label.stringValue = event.nvEvent().Label
	}
	
	private func setupCondition(event: CanvasEvent, doc: Document) {
		_condition.removeAllItems()
		doc.Story.Conditions.forEach{ _condition.addItem(withObjectValue: $0.Label) }
		
		let idx = _condition.indexOfItem(withObjectValue: event.nvEvent().PreCondition?.Label ?? "")
		if idx != NSNotFound {
			_condition.selectItem(at: idx)
		} else {
			_condition.stringValue = ""
		}
	}
	
	private func setupEntryFunction(event: CanvasEvent, doc: Document) {
		_entryFunction.removeAllItems()
		doc.Story.Functions.forEach{ _entryFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _entryFunction.indexOfItem(withObjectValue: event.nvEvent().EntryFunction?.Label ?? "")
		if idx != NSNotFound {
			_entryFunction.selectItem(at: idx)
		} else {
			_entryFunction.stringValue = ""
		}
	}
	
	private func setupDoFunction(event: CanvasEvent, doc: Document) {
		_doFunction.removeAllItems()
		doc.Story.Functions.forEach{ _doFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _doFunction.indexOfItem(withObjectValue: event.nvEvent().DoFunction?.Label ?? "")
		if idx != NSNotFound {
			_doFunction.selectItem(at: idx)
		} else {
			_doFunction.stringValue = ""
		}
	}
	
	private func setupExitFunction(event: CanvasEvent, doc: Document) {
		_exitFunction.removeAllItems()
		doc.Story.Functions.forEach{ _exitFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _exitFunction.indexOfItem(withObjectValue: event.nvEvent().ExitFunction?.Label ?? "")
		if idx != NSNotFound {
			_exitFunction.selectItem(at: idx)
		} else {
			_exitFunction.stringValue = ""
		}
	}
	
	private func setupActivations(event: CanvasEvent) {
		_activations.stringValue = "\(event.nvEvent().MaxActivations)"
	}
	
	private func setupTopmost(event: CanvasEvent) {
		_topmost.state = event.nvEvent().Topmost ? .on : .off
	}
	
	private func setupKeepAlive(event: CanvasEvent) {
		_keepAlive.state = event.nvEvent().KeepAlive ? .on : .off
	}
	
	private func setupEntry(event: CanvasEvent) {
		_entry.state = event.nvEvent().Parent?.Entry == event.nvEvent() ? .on : .off
	}
	
	private func setupParallel(event: CanvasEvent) {
		_parallel.state = event.nvEvent().Parallel ? .on : .off
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		_event?.nvEvent().Label = sender.stringValue
	}
	
	@IBAction func conditionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let event = _event else {
			return
		}
		
		let label = sender.stringValue
		guard let condition = doc.Story.Conditions.first(where: {$0.Label == label}) else {
			print("Could not find Condition: \(label). Setting to nil.")
			sender.stringValue = ""
			event.nvEvent().PreCondition = nil
			return
		}
		event.nvEvent().PreCondition = condition
	}
	
	@IBAction func entryFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let event = _event else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			event.nvEvent().EntryFunction = nil
			return
		}
		event.nvEvent().EntryFunction = function
	}
	
	@IBAction func doFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let event = _event else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			event.nvEvent().DoFunction = nil
			return
		}
		event.nvEvent().DoFunction = function
	}
	
	@IBAction func exitFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let event = _event else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			event.nvEvent().ExitFunction = nil
			return
		}
		event.nvEvent().ExitFunction = function
	}
	
	@IBAction func activationsDidChange(_ sender: NSTextField) {
		_event?.nvEvent().MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func topmostDidChange(_ sender: NSButton) {
		_event?.nvEvent().Topmost = sender.state == .on
	}
	
	@IBAction func keepAliveDidChange(_ sender: NSButton) {
		_event?.nvEvent().KeepAlive = sender.state == .on
	}
	
	@IBAction func entryDidChange(_ sender: NSButton) {
		_event?.nvEvent().Parent?.Entry = (sender.state == .on) ? _event?.nvEvent() : nil
		_event?.reloadData() // refresh entry icon
	}
	
	@IBAction func parallelDidChange(_ sender: NSButton) {
		_event?.nvEvent().Parallel = sender.state == .on
		_event?.reloadData() // refresh parallel icon
	}
}
