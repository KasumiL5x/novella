//
//  Popup.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

struct ToastSettings {
	var width: CGFloat
	var height: CGFloat
	var roundness: CGFloat
	var bgColor: NSColor
	var textColor: NSColor
	var fontSize: CGFloat
	var delay: Float
	var duration: Double
	var blur: Bool
	
	init() {
		self.width = 200.0
		self.height = 200.0
		self.roundness = 0.2
		self.bgColor = NSColor(white: 0.8, alpha: 0.7) //NSColor.fromHex("#686976").withAlphaComponent(0.5)
		self.textColor = NSColor.fromHex("#2d2d2d")
		self.fontSize = 42.0
		self.delay = 1.0
		self.duration = 2.5
		self.blur = false
	}
}

//class ToastAnimCB: NSObject, CAAnimationDelegate {
//	let _layer: CALayer
//
//	init(layer: CALayer) {
//		_layer = layer
//	}
//
//	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
////		_layer.backgroundFilters = []
////		_layer.setNeedsDisplay()
//	}
//}

extension NSView {
	func showToast(message: String, userSettings: ToastSettings?=nil) {
		// init default settings if not provided
		let settings: ToastSettings = userSettings ?? ToastSettings()
		
		// popup
		let popup = NSView(frame: NSMakeRect(
			self.frame.size.width/2 - settings.width/2,
			self.frame.height/2 - settings.height/2,
			settings.width,
			settings.height
		))
		// configure the popup layer
		popup.wantsLayer = true
		popup.layer?.backgroundColor = settings.bgColor.cgColor
		popup.layer?.masksToBounds = true
		// set corner radius of popup
		let fullyRounded = (max(popup.frame.width, popup.frame.height) * 0.5)
		popup.layer?.cornerRadius = fullyRounded * max(0.0, fabs(settings.roundness))
		
		// blur filter
		if settings.blur {
			popup.layerUsesCoreImageFilters = true
			popup.layer?.needsDisplayOnBoundsChange = true
			let blurFilter = CIFilter(name: "CIGaussianBlur")
			blurFilter?.setDefaults()
			blurFilter?.setValue(30.0, forKey: "inputRadius") // large values cause artifacting. why? maybe deal w/o blur :\.
			popup.layer?.backgroundFilters?.append(blurFilter!)
		}
		
		// label
		let label = NSTextField(labelWithString: message)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.alignment = .center
		label.font = NSFont(name: "Helvetica-Light", size: settings.fontSize)
		label.textColor = settings.textColor
		popup.addSubview(label)
		popup.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: popup, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		popup.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: popup, attribute: .centerY, multiplier: 1.0, constant: 0.0))
		
		// add actual popup
		self.addSubview(popup)
		
		// fade away w/ delay
		let delay = DispatchTimeInterval.milliseconds(Int(settings.delay * 1000))
		let duration = settings.duration
		DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
//			let anim = CABasicAnimation()
//			anim.keyPath = "backgroundFilters.CIGaussianBlur." + kCIInputRadiusKey
//			anim.fromValue = 20.5
//			anim.toValue = 0.0
//			anim.duration = 4.0
//			anim.delegate = ToastAnimCB(layer: popup.layer!)
//			popup.layer!.add(anim, forKey: "blurAnim")
			
			NSAnimationContext.runAnimationGroup({ (context) in
				context.duration = duration
				popup.animator().alphaValue = 0.0
			}, completionHandler: {
				popup.removeFromSuperview()
			})
			
		})
	}
}
