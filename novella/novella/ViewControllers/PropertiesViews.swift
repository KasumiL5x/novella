//
//  PropertiesViews.swift
//  novella
//
//  Created by Daniel Green on 04/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import AppKit

class PropertyTransformView: NSView, CanvasObjectDelegate {
	@IBOutlet weak private var _posX: NSTextField!
	@IBOutlet weak private var _posY: NSTextField!
	
	weak private var _currentObject: CanvasObject?
	
	static func instantiate() -> PropertyTransformView {
		guard let view: PropertyTransformView = initFromNib() else {
			fatalError()
		}
		return view
	}
	
	func enable() {
		_posX.isEnabled = true
		_posY.isEnabled = true
	}
	
	func disable() {
		_posX.stringValue = ""
		_posY.stringValue = ""
		_posX.isEnabled = false
		_posY.isEnabled = false
	}
	
	func setupFor(object: CanvasObject) {
		_currentObject = object
		_posX.stringValue = "\(object.frame.origin.x)"
		_posY.stringValue = "\(object.frame.origin.y)"
		object.add(delegate: self) // autoremoves itself once nil thanks to the hash map
	}
	
	@IBAction func onPosX(_ sender: NSTextField) {
		doMove()
	}
	
	@IBAction func doMove(_ sender: NSTextField) {
		doMove()
	}
	
	private func doMove() {
		// get x double
		guard let xfmt = (_posX.formatter as? NumberFormatter), let x = xfmt.number(from: _posX.stringValue)?.floatValue else {
			return
		}
		// get y double
		guard let yfmt = (_posY.formatter as? NumberFormatter), let y = yfmt.number(from: _posY.stringValue)?.floatValue else {
			return
		}
		_currentObject?.move(to: NSMakePoint(CGFloat(x), CGFloat(y)))
	}
	
	func canvasObjectMoved(obj: CanvasObject) {
		_posX.stringValue = "\(obj.frame.origin.x)"
		_posY.stringValue = "\(obj.frame.origin.y)"
	}
}

class PropertyGroupView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _maxActivations: NSTextField!
	@IBOutlet weak private var _topmost: NSButton!
	@IBOutlet weak var _keepAlive: NSButton!
	
	@IBOutlet weak private var _condition: NSPopUpButton!
	@IBOutlet weak var _entryFunction: NSPopUpButton!
	@IBOutlet weak var _exitFunction: NSPopUpButton!
	
	weak private var _doc: Document?
	weak private var _obj: CanvasGroup?
	
	static func instantiate() -> PropertyGroupView {
		guard let view: PropertyGroupView = initFromNib() else {
			fatalError()
		}
		return view
	}
	
	func setupFor(group: CanvasGroup, doc: Document) {
		_doc = doc
		_obj = group
		_label.stringValue = group.Group.Label
		_maxActivations.stringValue = "\(group.Group.MaxActivations)"
		_topmost.state = group.Group.Topmost ? .on : .off
		_keepAlive.state = group.Group.KeepAlive ? .on : .off
		
		// populate with all conditions + "None"
		_condition.menu?.removeAllItems()
		_condition.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for condition in doc.Story.Conditions {
			let item = NSMenuItem(title: condition.FunctionName, action: nil, keyEquivalent: "")
			item.representedObject = condition
			_condition.menu?.addItem(item)
		}
		// select actual assigned condition (if nil, then the default 'None' is okay)
		_condition.selectItem(withTitle: group.Group.PreCondition?.FunctionName ?? "None")
		
		// populate entry/exit functions
		_entryFunction.menu?.removeAllItems()
		_entryFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		_exitFunction.menu?.removeAllItems()
		_exitFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for function in doc.Story.Functions {
			// cannot use same NSMenuItem is two dropdowns, so make two
			let item_a = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_a.representedObject = function
			_entryFunction.menu?.addItem(item_a)
			
			let item_b = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_b.representedObject = function
			_exitFunction.menu?.addItem(item_b)
		}
		_entryFunction.selectItem(withTitle: group.Group.EntryFunction?.FunctionName ?? "None")
		_exitFunction.selectItem(withTitle: group.Group.ExitFunction?.FunctionName ?? "None")
	}
	
	@IBAction func onLabel(_ sender: NSTextField) {
		_obj?.Group.Label = sender.stringValue
	}
	
	@IBAction func onMaxActivations(_ sender: NSTextField) {
		_obj?.Group.MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func onTopmost(_ sender: NSButton) {
		_obj?.Group.Topmost = sender.state == .on
	}
	
	@IBAction func onKeepAlive(_ sender: NSButton) {
		_obj?.Group.KeepAlive = sender.state == .on
	}
	
	@IBAction func onCondition(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVCondition
		_obj?.Group.PreCondition = selection
	}
	
	@IBAction func onEntryFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Group.EntryFunction = selection
	}
	
	@IBAction func onExitFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Group.ExitFunction = selection
	}
}

class PropertySequenceView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _maxActivations: NSTextField!
	@IBOutlet weak private var _condition: NSPopUpButton!
	@IBOutlet weak private var _entryFunction: NSPopUpButton!
	@IBOutlet weak private var _exitFunction: NSPopUpButton!
	@IBOutlet weak private var _topmost: NSButton!
	@IBOutlet weak private var _keepAlive: NSButton!
	@IBOutlet weak private var _entry: NSButton!
	@IBOutlet weak private var _parallel: NSButton!
	
	weak private var _doc: Document?
	weak private var _obj: CanvasSequence?
	
	static func instantiate() -> PropertySequenceView {
		guard let view: PropertySequenceView = initFromNib() else {
			fatalError()
		}
		return view
	}
	
	func setupFor(sequence: CanvasSequence, doc: Document) {
		_doc = doc
		_obj = sequence
		_label.stringValue = sequence.Sequence.Label
		_maxActivations.stringValue = "\(sequence.Sequence.MaxActivations)"
		_topmost.state = sequence.Sequence.Topmost ? .on : .off
		_keepAlive.state = sequence.Sequence.KeepAlive ? .on : .off
		
		// populate with all conditions + "None"
		_condition.menu?.removeAllItems()
		_condition.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for condition in doc.Story.Conditions {
			let item = NSMenuItem(title: condition.FunctionName, action: nil, keyEquivalent: "")
			item.representedObject = condition
			_condition.menu?.addItem(item)
		}
		// select actual assigned condition (if nil, then the default 'None' is okay)
		_condition.selectItem(withTitle: sequence.Sequence.PreCondition?.FunctionName ?? "None")
		
		// populate entry/exit functions
		_entryFunction.menu?.removeAllItems()
		_entryFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		_exitFunction.menu?.removeAllItems()
		_exitFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for function in doc.Story.Functions {
			// cannot use same NSMenuItem is two dropdowns, so make two
			let item_a = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_a.representedObject = function
			_entryFunction.menu?.addItem(item_a)
			
			let item_b = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_b.representedObject = function
			_exitFunction.menu?.addItem(item_b)
		}
		_entryFunction.selectItem(withTitle: sequence.Sequence.EntryFunction?.FunctionName ?? "None")
		_exitFunction.selectItem(withTitle: sequence.Sequence.ExitFunction?.FunctionName ?? "None")
		
		_entry.state = sequence.Sequence.Parent?.Entry == sequence.Sequence ? .on : .off
		_parallel.state = sequence.Sequence.Parallel ? .on : .off
	}
	
	@IBAction func onLabel(_ sender: NSTextField) {
		_obj?.Sequence.Label = sender.stringValue
	}
	
	@IBAction func onMacActivations(_ sender: NSTextField) {
		_obj?.Sequence.MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func onCondition(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVCondition
		_obj?.Sequence.PreCondition = selection
	}
	
	@IBAction func onEntryFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Sequence.EntryFunction = selection
	}
	
	@IBAction func onExitFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Sequence.ExitFunction = selection
	}
	
	@IBAction func onTopmost(_ sender: NSButton) {
		_obj?.Sequence.Topmost = sender.state == .on
	}
	
	@IBAction func onKeepAlive(_ sender: NSButton) {
		_obj?.Sequence.KeepAlive = sender.state == .on
	}
	
	@IBAction func onEntry(_ sender: NSButton) {
		_obj?.Sequence.Parent?.Entry = sender.state == .on ? _obj?.Sequence : nil
	}
	
	@IBAction func onParallel(_ sender: NSButton) {
		_obj?.Sequence.Parallel = sender.state == .on
	}
}

class PropertyEventView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _maxActivations: NSTextField!
	@IBOutlet weak private var _condition: NSPopUpButton!
	@IBOutlet weak private var _entryFunction: NSPopUpButton!
	@IBOutlet weak private var _doFunction: NSPopUpButton!
	@IBOutlet weak private var _exitFunction: NSPopUpButton!
	@IBOutlet weak private var _instigators: NSPopUpButton!
	@IBOutlet weak private var _targets: NSPopUpButton!
	@IBOutlet weak private var _topmost: NSButton!
	@IBOutlet weak private var _keepAlive: NSButton!
	@IBOutlet weak private var _entry: NSButton!
	@IBOutlet weak private var _parallel: NSButton!
	
	weak private var _doc: Document?
	weak private var _obj: CanvasEvent?
	
	static func instantiate() -> PropertyEventView {
		guard let view: PropertyEventView = initFromNib() else {
			fatalError()
		}
		return view
	}
	
	func setupFor(event: CanvasEvent, doc: Document) {
		_doc = doc
		_obj = event
		_label.stringValue = event.Event.Label
		_maxActivations.stringValue = "\(event.Event.MaxActivations)"
		_topmost.state = event.Event.Topmost ? .on : .off
		_keepAlive.state = event.Event.KeepAlive ? .on : .off
		
		// populate with all conditions + "None"
		_condition.menu?.removeAllItems()
		_condition.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for condition in doc.Story.Conditions {
			let item = NSMenuItem(title: condition.FunctionName, action: nil, keyEquivalent: "")
			item.representedObject = condition
			_condition.menu?.addItem(item)
		}
		// select actual assigned condition (if nil, then the default 'None' is okay)
		_condition.selectItem(withTitle: event.Event.PreCondition?.FunctionName ?? "None")
		
		// populate entry/exit/do functions
		_entryFunction.menu?.removeAllItems()
		_entryFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		_exitFunction.menu?.removeAllItems()
		_exitFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		_doFunction.menu?.removeAllItems()
		_doFunction.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for function in doc.Story.Functions {
			// cannot use same NSMenuItem is two dropdowns, so make two
			let item_a = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_a.representedObject = function
			_entryFunction.menu?.addItem(item_a)
			
			let item_b = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_b.representedObject = function
			_exitFunction.menu?.addItem(item_b)

			let item_c = NSMenuItem(title: function.FunctionName, action: nil, keyEquivalent: "")
			item_c.representedObject = function
			_doFunction.menu?.addItem(item_c)
		}
		_entryFunction.selectItem(withTitle: event.Event.EntryFunction?.FunctionName ?? "None")
		_exitFunction.selectItem(withTitle: event.Event.ExitFunction?.FunctionName ?? "None")
		_doFunction.selectItem(withTitle: event.Event.DoFunction?.FunctionName ?? "None")
		
		// populate selectors
		_instigators.menu?.removeAllItems()
		_instigators.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		_targets.menu?.removeAllItems()
		_targets.menu?.addItem(withTitle: "None", action: nil, keyEquivalent: "")
		for selector in doc.Story.Selectors {
			let item_a = NSMenuItem(title: selector.UUID.uuidString, action: nil, keyEquivalent: "")
			item_a.representedObject = selector
			_instigators.menu?.addItem(item_a)
			
			let item_b = NSMenuItem(title: selector.UUID.uuidString, action: nil, keyEquivalent: "")
			item_b.representedObject = selector
			_targets.menu?.addItem(item_b)
		}
		_instigators.selectItem(withTitle: event.Event.Instigators?.UUID.uuidString ?? "None")
		_targets.selectItem(withTitle: event.Event.Targets?.UUID.uuidString ?? "None")
		
		_entry.state = event.Event.Parent?.Entry == event.Event ? .on : .off
		_parallel.state = event.Event.Parallel ? .on : .off
	}
	
	@IBAction func onLabel(_ sender: NSTextField) {
		_obj?.Event.Label = sender.stringValue
	}
	
	@IBAction func onMaxActivations(_ sender: NSTextField) {
		_obj?.Event.MaxActivations = Int(sender.stringValue) ?? 0
	}
	
	@IBAction func onCondition(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVCondition
		_obj?.Event.PreCondition = selection
	}
	
	@IBAction func onEntryFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Event.EntryFunction = selection
	}
	
	@IBAction func onDoFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Event.DoFunction = selection
	}
	
	@IBAction func onExitFunction(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVFunction
		_obj?.Event.ExitFunction = selection
	}
	
	@IBAction func onInstigators(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVSelector
		_obj?.Event.Instigators = selection
	}
	
	@IBAction func onTargets(_ sender: NSPopUpButton) {
		let selection = sender.selectedItem?.representedObject as? NVSelector
		_obj?.Event.Targets = selection
	}
	
	@IBAction func onTopmost(_ sender: NSButton) {
		_obj?.Event.Topmost = sender.state == .on
	}
	
	@IBAction func onKeepAlive(_ sender: NSButton) {
		_obj?.Event.KeepAlive = sender.state == .on
	}
	
	@IBAction func onEntry(_ sender: NSButton) {
		_obj?.Event.Parent?.Entry = sender.state == .on ? _obj?.Event : nil
	}
	
	@IBAction func onParallel(_ sender: NSButton) {
		_obj?.Event.Parallel = sender.state == .on
	}
}
