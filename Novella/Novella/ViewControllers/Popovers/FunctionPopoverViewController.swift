//
//  FunctionPopoverViewController.swift
//  Novella
//
//  Created by Daniel Green on 27/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel
import Highlightr

class FunctionPopoverViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet weak var _textView: NSView!
	@IBOutlet weak var _compileStatus: NSTextField!
	
	// MARK: - - Variables -
	fileprivate var _function: NVFunction?
	fileprivate let _textStorage = CodeAttributedString()
	fileprivate let _layoutManager = NSLayoutManager()
	fileprivate var _textContainer: NSTextContainer!
	fileprivate var _codeTextbox: NSTextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_function = nil
		
		_textStorage.language = "JavaScript"
		print(_textStorage.highlightr.setTheme(to: "dracula"))
		_textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
		_textStorage.setAttributedString(NSAttributedString(string: _function?.Javascript ?? "return true;"))
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
	
	func setFunction(function: NVFunction) {
		_function = function
		
		if isViewLoaded {
			_textStorage.setAttributedString(NSAttributedString(string: _function!.Javascript))
		}
	}
}

extension FunctionPopoverViewController: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		_function?.Javascript = _codeTextbox.string
	}
}
