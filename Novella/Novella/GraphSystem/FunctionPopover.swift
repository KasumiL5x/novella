//
//  FunctionPopover.swift
//  Novella
//
//  Created by Daniel Green on 27/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class FunctionPopover: GenericPopover {
	private var _trueFalse: Bool
	
	var TrueFalse: Bool {
		get{ return _trueFalse }
	}
	
	init(_ trueFalse: Bool) {
		_trueFalse = trueFalse
		super.init()
	}
	
	func setup(function: NVFunction) {
		(_popoverViewController as? FunctionPopoverViewController)?.setFunction(function: function)
		(_detachedViewController as? FunctionPopoverViewController)?.setFunction(function: function)
	}
	
	override func createViewController() -> NSViewController? {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Function")
		let vc = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return vc
	}
}
