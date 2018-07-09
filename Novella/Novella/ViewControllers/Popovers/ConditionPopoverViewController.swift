//
//  ConditionPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 25/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel
import Highlightr

class ConditionPopoverViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _textView: NSView!
	@IBOutlet private weak var _compileStatus: NSTextField!
	
	// MARK: - Variables -
	private var _condition: NVCondition?
	private let _textStorage = CodeAttributedString()
	private let _layoutManager = NSLayoutManager()
	private var _textContainer: NSTextContainer!
	private var _codeTextbox: NSTextView!
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_condition = nil
		
		_textStorage.language = "JavaScript"
		print(_textStorage.highlightr.setTheme(to: "dracula"))
		_textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
		_textStorage.addLayoutManager(_layoutManager)
		
		let textboxFrame = _textView.bounds
		_textContainer = NSTextContainer(size: textboxFrame.size)
		_layoutManager.addTextContainer(_textContainer)
		
		_codeTextbox = NSTextView(frame: textboxFrame, textContainer: _textContainer)
		_codeTextbox.autoresizingMask = [.width, .height]
		_codeTextbox.translatesAutoresizingMaskIntoConstraints = false
		_codeTextbox.backgroundColor = (_textStorage.highlightr.theme.themeBackgroundColor)
		_codeTextbox.insertionPointColor = NSColor.white
		_codeTextbox.isAutomaticQuoteSubstitutionEnabled = false
		_codeTextbox.isAutomaticDashSubstitutionEnabled = false
		_codeTextbox.allowsUndo = true
		_codeTextbox.delegate = self
		_textView.addSubview(_codeTextbox)
		_textView.addConstraints([
			NSLayoutConstraint(item: _codeTextbox, attribute: .left, relatedBy: .equal, toItem: _textView, attribute: .left, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .right, relatedBy: .equal, toItem: _textView, attribute: .right, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .top, relatedBy: .equal, toItem: _textView, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .bottom, relatedBy: .equal, toItem: _textView, attribute: .bottom, multiplier: 1.0, constant: 0)
		])
	}
	
	override func viewDidAppear() {
		refreshContent()
	}
	
	func setCondition(condition: NVCondition) {
		_condition = condition
		refreshContent()
	}
	
	func refreshContent() {
		_textStorage.setAttributedString(NSAttributedString(string: _condition?.Javascript ?? ""))
	}
}

extension ConditionPopoverViewController: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		_condition?.Javascript = _codeTextbox.string
	}
}
