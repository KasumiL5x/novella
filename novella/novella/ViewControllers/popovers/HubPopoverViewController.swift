//
//  HubPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 23/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class HubPopoverViewController: NSViewController {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _condition: NSComboBox!
	@IBOutlet weak private var _entryFunction: NSComboBox!
	@IBOutlet weak private var _returnFunction: NSComboBox!
	@IBOutlet weak private var _exitFunction: NSComboBox!
	
	weak private var _doc: Document?
	weak private var _hub: CanvasHub?
	
	func setup(hub: CanvasHub, doc: Document) {
		self._hub = hub
		self._doc = doc
		
		setupLabel(hub: hub)
		setupCondition(hub: hub, doc: doc)
		setupEntryFunction(hub: hub, doc: doc)
		setupReturnFunction(hub: hub, doc: doc)
		setupExitFunction(hub: hub, doc: doc)
	}
	
	private func setupLabel(hub: CanvasHub) {
		_label.stringValue = hub.nvHub().Label
	}
	
	private func setupCondition(hub: CanvasHub, doc: Document) {
		_condition.removeAllItems()
		doc.Story.Conditions.forEach{ _condition.addItem(withObjectValue: $0.Label) }
		
		let idx = _condition.indexOfItem(withObjectValue: hub.nvHub().Condition?.Label ?? "")
		if idx != NSNotFound {
			_condition.selectItem(at: idx)
		} else {
			_condition.stringValue = ""
		}
	}
	
	private func setupEntryFunction(hub: CanvasHub, doc: Document) {
		_entryFunction.removeAllItems()
		doc.Story.Functions.forEach{ _entryFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _entryFunction.indexOfItem(withObjectValue: hub.nvHub().EntryFunction?.Label ?? "")
		if idx != NSNotFound {
			_entryFunction.selectItem(at: idx)
		} else {
			_entryFunction.stringValue = ""
		}
	}
	
	private func setupReturnFunction(hub: CanvasHub, doc: Document) {
		_returnFunction.removeAllItems()
		doc.Story.Functions.forEach{ _returnFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _returnFunction.indexOfItem(withObjectValue: hub.nvHub().ReturnFunction?.Label ?? "")
		if idx != NSNotFound {
			_returnFunction.selectItem(at: idx)
		} else {
			_returnFunction.stringValue = ""
		}
	}
	
	private func setupExitFunction(hub: CanvasHub, doc: Document) {
		_exitFunction.removeAllItems()
		doc.Story.Functions.forEach{ _exitFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _exitFunction.indexOfItem(withObjectValue: hub.nvHub().ExitFunction?.Label ?? "")
		if idx != NSNotFound {
			_exitFunction.selectItem(at: idx)
		} else {
			_exitFunction.stringValue = ""
		}
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		_hub?.nvHub().Label = sender.stringValue
	}
	
	@IBAction func conditionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let hub = _hub else {
			return
		}
		
		let label = sender.stringValue
		guard let condition = doc.Story.Conditions.first(where: {$0.Label == label}) else {
			print("Could not find Condition: \(label). Setting to nil.")
			sender.stringValue = ""
			hub.nvHub().Condition = nil
			return
		}
		hub.nvHub().Condition = condition
	}
	
	@IBAction func entryFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let hub = _hub else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			hub.nvHub().EntryFunction = nil
			return
		}
		hub.nvHub().EntryFunction = function
	}
	
	@IBAction func returnFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let hub = _hub else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			hub.nvHub().ReturnFunction = nil
			return
		}
		hub.nvHub().ReturnFunction = function
	}
	
	@IBAction func exitFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let hub = _hub else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			hub.nvHub().ExitFunction = nil
			return
		}
		hub.nvHub().ExitFunction = function
	}
}
