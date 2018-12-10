//
//  CanvasLink.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasLink: NSView {
	static let Size: CGFloat = 20.0
	static let OutlineInset: CGFloat = 3.0
	static let FillInset: CGFloat = 1.5
	
	private let _outlineLayer: CAShapeLayer
	private let _fillLayer: CAShapeLayer
	
	init() {
		self._outlineLayer = CAShapeLayer()
		self._fillLayer = CAShapeLayer()
		super.init(frame: NSMakeRect(0, 0, CanvasLink.Size, CanvasLink.Size))
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// background first
		let bgLayer = CAShapeLayer()
		bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05).cgColor
		bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: 4.0, yRadius: 4.0).cgPath
		layer?.addSublayer(bgLayer)
		
		// outline
		let outlineRect = bounds.insetBy(dx: CanvasLink.OutlineInset, dy: CanvasLink.OutlineInset)
		_outlineLayer.lineWidth = 1.0
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.5).cgColor
		_outlineLayer.path = NSBezierPath(ovalIn: outlineRect).cgPath
		layer?.addSublayer(_outlineLayer)
		
		// fill
		let fillRect = outlineRect.insetBy(dx: CanvasLink.FillInset, dy: CanvasLink.FillInset)
		_fillLayer.strokeColor = nil
		_fillLayer.fillColor = CGColor.clear
		_fillLayer.path = NSBezierPath(ovalIn: fillRect).cgPath
		layer?.addSublayer(_fillLayer)
	}
	
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
}
