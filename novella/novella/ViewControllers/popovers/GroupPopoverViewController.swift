//
//  GroupPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 07/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class GroupPopoverViewController: NSViewController {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _condition: NSComboBox!
	@IBOutlet weak private var _entryFunction: NSComboBox!
	@IBOutlet weak private var _exitFunction: NSComboBox!
	@IBOutlet weak private var _activations: NSTextField!
	@IBOutlet weak private var _topmost: NSButton!
	@IBOutlet weak private var _keepAlive: NSButton!
	@IBOutlet weak private var _attributesTable: NSTableView!
	
	weak private var _doc: Document?
	weak private var _group: CanvasGroup?
	
	func setup(group: CanvasGroup, doc: Document) {
		self._group = group
		self._doc = doc
		
		setupLabel(group: group)
		setupCondition(group: group, doc: doc)
		setupEntryFunction(group: group, doc: doc)
		setupExitFunction(group: group, doc: doc)
		setupActivations(group: group)
		setupTopmost(group: group)
		setupKeepAlive(group: group)
	}
	
	private func setupLabel(group: CanvasGroup) {
		_label.stringValue = group.Group.Label
	}
	
	private func setupCondition(group: CanvasGroup, doc: Document) {
		_condition.removeAllItems()
		doc.Story.Conditions.forEach{ _condition.addItem(withObjectValue: $0.Label) }
		
		let idx = _condition.indexOfItem(withObjectValue: group.Group.PreCondition?.Label ?? "")
		if idx != NSNotFound {
			_condition.selectItem(at: idx)
		} else {
			_condition.stringValue = ""
		}
	}
	
	private func setupEntryFunction(group: CanvasGroup, doc: Document) {
		_entryFunction.removeAllItems()
		doc.Story.Functions.forEach{ _entryFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _entryFunction.indexOfItem(withObjectValue: group.Group.EntryFunction?.Label ?? "")
		if idx != NSNotFound {
			_entryFunction.selectItem(at: idx)
		} else {
			_entryFunction.stringValue = ""
		}
	}
	
	private func setupExitFunction(group: CanvasGroup, doc: Document) {
		_exitFunction.removeAllItems()
		doc.Story.Functions.forEach{ _exitFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _exitFunction.indexOfItem(withObjectValue: group.Group.ExitFunction?.Label ?? "")
		if idx != NSNotFound {
			_exitFunction.selectItem(at: idx)
		} else {
			_exitFunction.stringValue = ""
		}
	}
	
	private func setupActivations(group: CanvasGroup) {
		_activations.stringValue = "\(group.Group.MaxActivations)"
	}
	
	private func setupTopmost(group: CanvasGroup) {
		_topmost.state = group.Group.Topmost ? .on : .off
	}
	
	private func setupKeepAlive(group: CanvasGroup) {
		_keepAlive.state = group.Group.KeepAlive ? .on : .off
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		_group?.Group.Label = sender.stringValue
	}
	
	@IBAction func conditionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let group = _group else {
			return
		}
		
		let label = sender.stringValue
		guard let condition = doc.Story.Conditions.first(where: {$0.Label == label}) else {
			print("Could not find Condition: \(label). Setting to nil.")
			sender.stringValue = ""
			group.Group.PreCondition = nil
			return
		}
		group.Group.PreCondition = condition
	}
	
	@IBAction func entryFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let group = _group else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			group.Group.EntryFunction = nil
			return
		}
		group.Group.EntryFunction = function
	}
	
	@IBAction func exitFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let group = _group else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			group.Group.ExitFunction = nil
			return
		}
		group.Group.ExitFunction = function
	}
	
	@IBAction func activationsDidChange(_ sender: NSTextField) {
		_group?.Group.MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func topmostDidChange(_ sender: NSButton) {
		_group?.Group.Topmost = sender.state == .on
	}
	
	@IBAction func keepAliveDidChange(_ sender: NSButton) {
		_group?.Group.KeepAlive = sender.state == .on
	}
}
