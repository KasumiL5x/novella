//
//  TypewriterLabel
//  Novella
//
//  https://github.com/wibosco/GhostTypewriter
//  Created by William Boles on 19/12/2016.
//  Converted to AppKit and further modified by Daniel Green on 24 June 2018.
//  Copyright © 2016 Boles, 2018 Green. All rights reserved.
//

import AppKit

/// A UILabel subclass that adds a ghost type writing animation effect.
public class TypewriterLabel: NSTextField {
	
	/// Interval (time gap) between each character being animated on screen.
	public var typingTimeInterval: TimeInterval = 0.05
	
	/// Timer instance that control's the animation.
	private var animationTimer: Timer?
	
	// Desired string (used whens skipping).
	private var desiredAttributedString: NSAttributedString = NSAttributedString()
	
	/// Allows for text to be hidden before animation begins.
	public var hideTextBeforeTypewritingAnimation = true {
		didSet {
			configureTransparency()
		}
	}
	
	/// Tracks the location of the next character using UTF16 encoding.
	private var utf16CharacterLocation = 0
	
	// MARK: - Lifecycle
	
	/**
	Triggered when label is added to superview, will configure label with provided transparency.
	
	- Parameter toWindow/toSuperview: window/view that label is added to.
	*/
	public override func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		configureTransparency()
	}
	public override func viewWillMove(toSuperview newSuperview: NSView?) {
		super.viewWillMove(toSuperview: newSuperview)
		configureTransparency()
	}
	
	/**
	Tidies the animation up if it's still in progress by invalidating the timer.
	*/
	deinit {
		animationTimer?.invalidate()
	}
	
	// MARK: - TypingAnimation
	
	/**
	Starts the type writing animation.
	
	- Parameter completion: a callback block/closure for when the type writing animation is complete. This can be useful for chaining multiple animations together.
	*/
	public func startTypewritingAnimation(completion: (() -> Void)?) {
		desiredAttributedString = self.attributedStringValue
		setAttributedTextColorToTransparent()
		stopTypewritingAnimation()
		var animateUntilCharacterIndex = 0
		let charactersCount = attributedStringValue.length
		utf16CharacterLocation = 0
		
		animationTimer = Timer.scheduledTimer(withTimeInterval: typingTimeInterval, repeats: true, block: { (timer: Timer) in
			if animateUntilCharacterIndex < charactersCount {
				self.setAlphaOnAttributedText(alpha: CGFloat(1), characterIndex: animateUntilCharacterIndex)
				animateUntilCharacterIndex += 1
			} else {
				completion?()
				self.stopTypewritingAnimation()
			}
		})
	}
	
	/**
	Stops the type writing animation.
	*/
	public func stopTypewritingAnimation() {
		animationTimer?.invalidate()
		animationTimer = nil
	}
	
	/**
	Cancels the typing animation and can clear label's content if `clear` is `true`.
	
	- Parameter clear: sets label's content to transparent when animation is cancelled.
	*/
	public func cancelTypewritingAnimation(clearText: Bool = true) {
		if clearText {
			setAttributedTextColorToTransparent()
		}
		stopTypewritingAnimation()
	}
	
	/**
	Skips the type writing animation.
	*/
	public func skipTypewritingAnimation() {
		stopTypewritingAnimation()
		self.attributedStringValue = desiredAttributedString
		setAttributedTextColorToOpaque()
	}
	
	// MARK: - Configure
	
	/**
	Adjust transparency to match value set for `hideTextBeforeTypewritingAnimation`.
	*/
	private func configureTransparency() {
		if hideTextBeforeTypewritingAnimation {
			setAttributedTextColorToTransparent()
		} else {
			setAttributedTextColorToOpaque()
		}
	}
	
	/**
	Adjusts the alpha value on the attributed string so that it is transparent.
	*/
	private func setAttributedTextColorToTransparent() {
		if hideTextBeforeTypewritingAnimation {
			setAlphaOnAttributedText(alpha: CGFloat(0))
		}
	}
	
	/**
	Adjusts the alpha value on the attributed string so that it is opaque.
	*/
	private func setAttributedTextColorToOpaque() {
		if !hideTextBeforeTypewritingAnimation {
			setAlphaOnAttributedText(alpha: CGFloat(1))
		}
	}
	
	/**
	Adjusts the alpha value on the full attributed string.
	
	- Parameter alpha: alpha value the attributed string's characters will be set to.
	*/
	private func setAlphaOnAttributedText(alpha: CGFloat) {
		let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
		attributedString.addAttribute(.foregroundColor, value: textColor?.withAlphaComponent(alpha) ?? NSColor.textColor, range: NSRange(location:0, length: attributedStringValue.length))
		self.attributedStringValue = attributedString
	}
	
	/**
	Adjusts the alpha value on the attributed string until (inclusive) a certain character length.
	
	- Parameter alpha: alpha value the attributed string's characters will be set to.
	- Parameter characterIndex: upper bound of attributed string's characters that the alpha value will be applied to.
	*/
	private func setAlphaOnAttributedText(alpha: CGFloat, characterIndex: Int) {
		let attributedString = NSMutableAttributedString(attributedString: attributedStringValue)
		let index = attributedString.string.index(attributedString.string.startIndex, offsetBy: characterIndex)
		let character = "\(attributedString.string[index])"
		let count = character.utf16.count
		attributedString.addAttribute(.foregroundColor, value: textColor?.withAlphaComponent(alpha) ?? NSColor.textColor, range: NSRange(location: utf16CharacterLocation, length: count))
		self.attributedStringValue = attributedString
		
		utf16CharacterLocation += count
	}
}
