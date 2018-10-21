//
//  ConditionPopoverViewController.swift
//  novella
//
//  Created by Daniel Green on 21/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit
import Highlightr

class ConditionPopoverViewController: NSViewController {
	private let _textStorage = CodeAttributedString()
	private var _codeTextbox: NSTextView!
	
	var Condition: NVCondition? {
		didSet {
			_textStorage.setAttributedString(NSAttributedString(string: Condition?.JavaScript ?? "ERROR"))
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let layoutManager = NSLayoutManager()
		
		_textStorage.language = "JavaScript"
		_textStorage.highlightr.setTheme(to: "github-gist")
		_textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
		_textStorage.addLayoutManager(layoutManager)
		
		let textboxFrame = view.bounds
		let textContainer = NSTextContainer(size: textboxFrame.size)
		layoutManager.addTextContainer(textContainer)
		
		_codeTextbox = NSTextView(frame: textboxFrame, textContainer: textContainer)
		_codeTextbox.autoresizingMask = [.width, .height]
		_codeTextbox.backgroundColor = (_textStorage.highlightr.theme.themeBackgroundColor)
		_codeTextbox.insertionPointColor = NSColor.black
		_codeTextbox.isAutomaticQuoteSubstitutionEnabled = false
		_codeTextbox.isAutomaticDashSubstitutionEnabled = false
		_codeTextbox.allowsUndo = true
		_codeTextbox.isEditable = true
		_codeTextbox.delegate = self
		view.addSubview(_codeTextbox)
		_codeTextbox.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: _codeTextbox, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .top,   relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -30)
		])
	}
}

extension ConditionPopoverViewController: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		Condition?.JavaScript = _codeTextbox.string
	}
}
