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
	// MARK: - - Outlets -
	@IBOutlet weak var _textView: NSView!
	@IBOutlet weak var _compileStatus: NSTextField!
	
	// MARK: - - Variables -
	fileprivate var _condition: NVCondition?
	fileprivate let _textStorage = CodeAttributedString()
	fileprivate let _layoutManager = NSLayoutManager()
	fileprivate var _textContainer: NSTextContainer!
	fileprivate var _codeTextbox: NSTextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_condition = nil
		
		_textStorage.language = "JavaScript"
		print(_textStorage.highlightr.setTheme(to: "dracula"))
		_textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
		_textStorage.setAttributedString(NSAttributedString(string: _condition?.Javascript ?? "return true;"))
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
		_codeTextbox.delegate = self
		_textView.addSubview(_codeTextbox)
		_textView.addConstraints([
			NSLayoutConstraint(item: _codeTextbox, attribute: .left, relatedBy: .equal, toItem: _textView, attribute: .left, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .right, relatedBy: .equal, toItem: _textView, attribute: .right, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .top, relatedBy: .equal, toItem: _textView, attribute: .top, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: _codeTextbox, attribute: .bottom, relatedBy: .equal, toItem: _textView, attribute: .bottom, multiplier: 1.0, constant: 0)
		])
	}
	
	func setCondition(condition: NVCondition) {
		_condition = condition
		
		if isViewLoaded {
			_textStorage.setAttributedString(NSAttributedString(string: _condition!.Javascript))
		}
	}
}

extension ConditionPopoverViewController: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		_condition?.Javascript = _codeTextbox.string
	}
}
