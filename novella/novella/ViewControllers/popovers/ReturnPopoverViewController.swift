//
//  ReturnPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 24/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class ReturnPopoverViewController: NSViewController {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _exitFunction: NSComboBox!
	
	weak private var _doc: Document?
	weak private var _rtrn: CanvasReturn?
	
	func setup(rtrn: CanvasReturn, doc: Document) {
		self._rtrn = rtrn
		self._doc = doc
		
		setupLabel(rtrn: rtrn)
		setupExitFunction(rtrn: rtrn, doc: doc)
	}
	
	private func setupLabel(rtrn: CanvasReturn) {
		_label.stringValue = rtrn.nvReturn().Label
	}
	
	private func setupExitFunction(rtrn: CanvasReturn, doc: Document) {
		_exitFunction.removeAllItems()
		doc.Story.Functions.forEach{ _exitFunction.addItem(withObjectValue: $0.Label) }
		
		let idx = _exitFunction.indexOfItem(withObjectValue: rtrn.nvReturn().ExitFunction?.Label ?? "")
		if idx != NSNotFound {
			_exitFunction.selectItem(at: idx)
		} else {
			_exitFunction.stringValue = ""
		}
	}
	
	@IBAction func labelDidChange(_ sender: NSTextField) {
		_rtrn?.nvReturn().Label = sender.stringValue
	}
	
	
	@IBAction func exitFunctionDidChange(_ sender: NSComboBox) {
		guard let doc = _doc, let rtrn = _rtrn else {
			return
		}
		
		let label = sender.stringValue
		guard let function = doc.Story.Functions.first(where: {$0.Label == label}) else {
			print("Could not find Function: \(label). Setting to nil.")
			sender.stringValue = ""
			rtrn.nvReturn().ExitFunction = nil
			return
		}
		rtrn.nvReturn().ExitFunction = function
	}
}
