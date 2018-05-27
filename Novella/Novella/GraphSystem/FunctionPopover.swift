//
//  FunctionPopover.swift
//  Novella
//
//  Created by Daniel Green on 27/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class FunctionPopover: GenericPopover {
	fileprivate var _trueFalse: Bool
	
	var TrueFalse: Bool {
		get{ return _trueFalse }
	}
	
	init(_ trueFalse: Bool) {
		_trueFalse = trueFalse
		super.init()
	}
	
	override func createViewController() -> Bool {
		let popoverStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Popovers"), bundle: nil)
		let popoverID = NSStoryboard.SceneIdentifier(rawValue: "Function")
		_viewController = popoverStoryboard.instantiateController(withIdentifier: popoverID) as? NSViewController
		
		return _viewController != nil
	}
}
