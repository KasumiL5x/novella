//
//  WriterViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class WriterViewController: NSViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		// https://stackoverflow.com/questions/42342231/how-to-show-touch-bar-in-a-viewcontroller
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
		self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
	}
	deinit {
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
	}
}

// MARK: TouchBar
extension WriterViewController {
	
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.customizationIdentifier = TouchBarIdentifiers.Test
		touchBar.defaultItemIdentifiers = [TouchBarIdentifiers.InfoLabelItem]
		touchBar.customizationAllowedItemIdentifiers = [TouchBarIdentifiers.InfoLabelItem]
		touchBar.principalItemIdentifier = TouchBarIdentifiers.InfoLabelItem
		return touchBar
	}
}

extension WriterViewController: NSTouchBarDelegate {
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		switch identifier {
		case TouchBarIdentifiers.InfoLabelItem:
			return NSColorPickerTouchBarItem.colorPicker(withIdentifier: identifier)
		default:
			return nil
		}
	}
}
