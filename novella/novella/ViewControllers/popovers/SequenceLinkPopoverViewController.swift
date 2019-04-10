//
//  SequenceLinkPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 10/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class SequenceLinkPopoverViewController: NSViewController {
	@IBOutlet weak private var _condition: NSComboBox!
	@IBOutlet weak private var _function: NSComboBox!
	
	weak private var _doc: Document?
	weak private var _link: CanvasSequenceLink?
	
	func setup(link: CanvasSequenceLink, doc: Document) {
		self._link = link
		self._doc = doc
		
		setupCondition(link: link, doc: doc)
		setupFunction(link: link, doc: doc)
	}
	
	private func setupCondition(link: CanvasSequenceLink, doc: Document) {
		_condition.removeAllItems()
		doc.Story.Conditions.forEach{ _condition.addItem(withObjectValue: $0.Label) }
		
		let idx = _condition.indexOfItem(withObjectValue: link.SequenceLink.Condition?.Label ?? "")
		if idx != NSNotFound {
			_condition.selectItem(at: idx)
		} else {
			_condition.stringValue = ""
		}
	}
	
	private func setupFunction(link: CanvasSequenceLink, doc: Document) {
		_function.removeAllItems()
		doc.Story.Functions.forEach{ _function.addItem(withObjectValue: $0.Label) }
		
		let idx = _function.indexOfItem(withObjectValue: link.SequenceLink.Function?.Label ?? "")
		if idx != NSNotFound {
			_function.selectItem(at: idx)
		} else {
			_function.stringValue = ""
		}
	}
	
	@IBAction func conditionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let link = _link else {
			return
		}
		
		let label = sender.stringValue
		guard let condition = doc.Story.Conditions.first(where: {$0.Label == label}) else {
			print("Could not find Condition: \(label). Setting to nil.")
			sender.stringValue = ""
			link.SequenceLink.Condition = nil
			return
		}
		link.SequenceLink.Condition = condition
	}
	
	@IBAction func functionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let link = _link else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			link.SequenceLink.Function = nil
			return
		}
		link.SequenceLink.Function = function
	}
}
