//
//  NSView+Toast.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ToastView: NSView {
	private var _backgroundLayer: CALayer!
	private var _tintColor: NSColor = NSColor(calibratedWhite: 1.0, alpha: 0.7)
	private var _saturationFactor: Float = 2.0
	private var _blurRadius: Float = 20.0
	private var _roundness: CGFloat = 0.2
	private var _textField: NSTextField!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}
	
	var Tint: NSColor {
		get{ return _tintColor }
		set{
			_tintColor = newValue
			self.layer?.backgroundColor = _tintColor.cgColor
			self.layer?.setNeedsDisplay()
		}
	}
	
	var Blur: Float {
		get{ return _blurRadius }
		set{
			_blurRadius = newValue
			resetFilters()
		}
	}
	
	var Saturation: Float {
		get{ return _saturationFactor }
		set{
			_saturationFactor = newValue
			resetFilters()
		}
	}
	
	var Roundness: CGFloat {
		get{ return _roundness }
		set{
			_roundness = newValue
			let fullyRounded = (max(frame.width, frame.height) * 0.5)
			self.layer?.cornerRadius = fullyRounded * max(0.0, fabs(_roundness))
			self.layer?.setNeedsDisplay()
		}
	}
	
	var Text: String {
		get{ return _textField.stringValue }
		set{
			_textField.stringValue = newValue
			fitText()
		}
	}
	
	var TextColor: NSColor {
		get{ return _textField.textColor! }
		set{ _textField.textColor = newValue }
	}
	
	func setup() {
		self.wantsLayer = true
		_backgroundLayer = CALayer(layer: self.layer!)
		self.layer = _backgroundLayer
		
		self.layer!.masksToBounds = true
		self.layerUsesCoreImageFilters = true
		self.layer!.needsDisplayOnBoundsChange = true
		Tint = _tintColor
		Roundness = _roundness
		
		_textField = NSTextField(labelWithString: "")
		_textField.translatesAutoresizingMaskIntoConstraints = false
		_textField.alignment = .center
		_textField.font = NSFont(name: "Helvetica-Light", size: 82.0)
		_textField.textColor = NSColor.black
		self.addSubview(_textField)
		self.addConstraints([
			NSLayoutConstraint(item: _textField, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: _textField, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: _textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		])
		Text = "default"
		
		
		resetFilters()
	}
	
	func fitText() {
		// this is horribly inefficient, but it works (https://stackoverflow.com/questions/2908704/get-nstextfield-contents-to-scale/2911982#2911982)
		let xMargin: CGFloat = self.frame.width * 0.1
		let targetWidth = self.frame.width - xMargin
		
		let minFontSize = 6
		let maxFontSize = 100
		var fontSize: CGFloat = 0.0
		for i in minFontSize...maxFontSize {
			let attrs: [NSAttributedStringKey: Any] = [
				NSAttributedStringKey.font: NSFont(name: (_textField.font?.fontName)!, size: CGFloat(i))!
			]
			let strSize = NSString(string: _textField.stringValue).size(withAttributes: attrs)
			if strSize.width >= targetWidth {
				fontSize = CGFloat(i-1)
				break
			}
		}
		_textField.font = NSFont(name: _textField.font!.fontName, size: fontSize)
	}
	
	func resetFilters() {
		if let saturationFilter = CIFilter(name: "CIColorControls", withInputParameters: ["inputSaturation": _saturationFactor]),
			 let blurFilter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": _blurRadius]) {
			self.layer?.backgroundFilters = [saturationFilter, blurFilter]
			self.layer?.setNeedsDisplay()
		}
	}
}

struct ToastSettings {
	var width: CGFloat
	var height: CGFloat
	var roundness: CGFloat
	var tint: NSColor
	var textColor: NSColor
	var fontSize: CGFloat
	var delay: Float
	var duration: Double
	
	init() {
		self.width = 200.0
		self.height = 200.0
		self.roundness = 0.2
		self.tint = NSColor(calibratedWhite: 1.0, alpha: 0.7)
		self.textColor = NSColor.fromHex("#2d2d2d")
		self.fontSize = 42.0
		self.delay = 1.0
		self.duration = 0.3
	}
}

extension NSView {
	func showToast(message: String, userSettings: ToastSettings?=nil) {
		// init default settings if not provided
		let settings: ToastSettings = userSettings ?? ToastSettings()
		
		// popup
		let popup = ToastView(frame: NSMakeRect(
			self.frame.size.width/2 - settings.width/2,
			self.frame.height/2 - settings.height/2,
			settings.width,
			settings.height
		))
		
		popup.Roundness = settings.roundness
		popup.Tint = settings.tint
		popup.Text = message
		popup.TextColor = settings.textColor
		
		// add actual popup above everything else
		self.addSubview(popup, positioned: .above, relativeTo: nil)
		
		// fade away w/ delay
		let delay = DispatchTimeInterval.milliseconds(Int(settings.delay * 1000))
		let duration = settings.duration
		DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
			let blurAnim = CABasicAnimation()
			blurAnim.keyPath = "backgroundFilters.CIGaussianBlur.inputRadius"
			blurAnim.fromValue = popup.Blur
			blurAnim.toValue = 0.0
			blurAnim.duration = duration * 0.1
			blurAnim.fillMode = kCAFillModeForwards
			blurAnim.isRemovedOnCompletion = false
			popup.layer!.add(blurAnim, forKey: "blurAnim")
			
			let satAnim = CABasicAnimation()
			satAnim.keyPath = "backgroundFilters.CIColorControls.inputSaturation"
			satAnim.fromValue = popup.Saturation
			satAnim.toValue = 1.0
			satAnim.duration = duration * 0.1
			satAnim.fillMode = kCAFillModeForwards
			satAnim.isRemovedOnCompletion = false
			popup.layer?.add(satAnim, forKey: "satAnim")
			
			NSAnimationContext.runAnimationGroup({ (context) in
				context.duration = duration
				popup.animator().alphaValue = 0.0
			}, completionHandler: {
				popup.removeFromSuperview()
			})
			
		})
	}
}
