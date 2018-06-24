//
//  CLTypingLabel.swift
//  CLTypingLabel
//  The MIT License (MIT)
//  Copyright © 2016 Chenglin 2/21/16.
//  Updated to AppKit's NSTextField and other various Swift fixes 21 June 2018 by Daniel Green.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files
//  (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit

/*
Set text at runtime to trigger type animation;

Set charInterval property for interval time between each character, default is 0.1;

Call pauseTyping() to pause animation;

Call conitinueTyping() to continue paused animation;
*/


@IBDesignable open class CLTypingLabel: NSTextField {
	/*
	Set interval time between each characters
	*/
	@IBInspectable open var charInterval: Double = 0.05
	
	/*
	If text is always centered during typing
	*/
	@IBInspectable open var centerText: Bool = false
	
	private var typingStopped: Bool = false
	private var typingOver: Bool = true
	private var stoppedSubstring: String?
	private var attributes: [NSAttributedStringKey: Any]?
	private var currentDispatchID: Int = 320
	private let dispatchSerialQ = DispatchQueue(label: "CLTypingLableQueue")
	private var desiredText: String = ""
	/*
	Setting the text will trigger animation automatically
	*/
	open override var stringValue: String {
		get {
			return super.stringValue
		}
		set {
			if charInterval < 0 {
				charInterval = -charInterval
			}
			
			currentDispatchID += 1
			typingStopped = false
			typingOver = false
			stoppedSubstring = nil
			
			desiredText = newValue
			attributes = nil
			setTextWithTypingAnimation(newValue, attributes,charInterval, true, currentDispatchID)
		}
	}
	
	/*
	Setting attributed text will trigger animation automatically
	*/
	open override var attributedStringValue: NSAttributedString {
		get {
			return super.attributedStringValue
		}
		set {
			if charInterval < 0 {
				charInterval = -charInterval
			}
			
			currentDispatchID += 1
			typingStopped = false
			typingOver = false
			stoppedSubstring = nil
			
			desiredText = newValue.string
			attributes = newValue.attributes(at: 0, effectiveRange: nil)
			setTextWithTypingAnimation(newValue.string, attributes,charInterval, true, currentDispatchID)
		}
	}
	
	// MARK: -
	// MARK: Stop Typing Animation
	
	open func pauseTyping() {
		if typingOver == false {
			typingStopped = true
		}
	}
	
	// MARK: -
	// MARK: Skip Typing Animation
	open func skipTyping() {
		typingOver = true
		typingStopped = true
		super.stringValue = desiredText
	}
	
	// MARK: -
	// MARK: Continue Typing Animation
	
	open func continueTyping() {
		
		guard typingOver == false else {
			print("CLTypingLabel: Animation is already over")
			return
		}
		
		guard typingStopped == true else {
			print("CLTypingLabel: Animation is not stopped")
			return
		}
		guard let stoppedSubstring = stoppedSubstring else {
			return
		}
		
		typingStopped = false
		setTextWithTypingAnimation(stoppedSubstring, attributes ,charInterval, false, currentDispatchID)
	}
	
	// MARK: -
	// MARK: Set Text Typing Recursive Loop
	
	private func setTextWithTypingAnimation(_ typedText: String, _ attributes: Dictionary<NSAttributedStringKey, Any>?, _ charInterval: TimeInterval, _ initial: Bool, _ dispatchID: Int) {
		
		guard typedText.count > 0 && currentDispatchID == dispatchID else {
			typingOver = true
			typingStopped = false
			return
		}
		
		guard typingStopped == false else {
			stoppedSubstring = typedText
			return
		}
		
		if initial == true {
			super.stringValue = ""
		}
		
		let firstCharIndex = typedText.index(typedText.startIndex, offsetBy: 1)
		
		DispatchQueue.main.async {
			if let attributes = attributes {
				super.attributedStringValue = NSAttributedString(string: super.attributedStringValue.string +  String(typedText[..<firstCharIndex]),
																									attributes: attributes)
			} else {
				super.stringValue = super.stringValue + String(typedText[..<firstCharIndex])
			}
			
			if self.centerText == true {
				self.sizeToFit()
			}
			self.dispatchSerialQ.asyncAfter(deadline: .now() + charInterval) { [weak self] in
				let nextString = String(typedText[firstCharIndex...])
				
				self?.setTextWithTypingAnimation(nextString, attributes, charInterval, false, dispatchID)
			}
		}
		
	}
}
