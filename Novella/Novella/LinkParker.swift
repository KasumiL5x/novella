//
//  LinkParker.swift
//  novella
//
//  Created by Daniel Green on 22/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class LinkParker: NSView {
	override var tag: Int {
		return 0
	}
	
	private var _bgLayer: CAShapeLayer = CAShapeLayer()
	private var _outlineLayer: CAShapeLayer = CAShapeLayer()
	private var _parkedLink: CanvasLink? = nil
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		sharedInit()
	}
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		sharedInit()
	}
	
	private func sharedInit() {
		wantsLayer = true
		layer?.masksToBounds = false
		
		_outlineLayer.path = NSBezierPath(ovalIn: bounds).cgPath
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.3).cgColor
		_outlineLayer.lineWidth = 4.0
		layer?.addSublayer(_outlineLayer)
		
		_bgLayer.path = NSBezierPath(ovalIn: bounds).cgPath
		_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
		_bgLayer.strokeColor = nil
		layer?.addSublayer(_bgLayer)
	}
	
	func prime() {
		_bgLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.4).cgColor
		_outlineLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.2).cgColor
		_outlineLayer.lineWidth = 10.0
	}
	
	func unprime() {
		_bgLayer.fillColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.6).cgColor
		_outlineLayer.strokeColor = NSColor.fromHex("#12e2a3").withAlphaComponent(0.3).cgColor
		_outlineLayer.lineWidth = 4.0
	}
	
	func park(_ link: CanvasLink) {
		_parkedLink = link
		_bgLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.4).cgColor
		_outlineLayer.fillColor = NSColor.fromHex("#26baee").withAlphaComponent(0.2).cgColor
		_outlineLayer.lineWidth = 15.0

	}
}
