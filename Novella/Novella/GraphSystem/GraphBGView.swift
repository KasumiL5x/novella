//
//  GraphBGView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class GraphBGView: NSView {
	// color
	fileprivate var _backgroundColor: NSColor
	fileprivate var _lineColor: NSColor
	// opacity
	fileprivate var _majorOpacity: CGFloat
	fileprivate var _minorOpacity: CGFloat
	fileprivate var _opacity: CGFloat
	// thickness
	fileprivate var _majorThickness: CGFloat
	fileprivate var _minorThickness: CGFloat
	fileprivate var _thickness: CGFloat
	// divisors
	fileprivate var _majorDivisor: Int
	fileprivate var _minorDivisor: Int
	// depth
	fileprivate var _density: CGFloat
	
	override init(frame frameRect: NSRect) {
		self._backgroundColor = NSColor.fromHex("#36363d")
		self._lineColor = NSColor.fromHex("#787878")
		//
		self._majorOpacity = CGFloat(0.5)
		self._minorOpacity = CGFloat(0.4)
		self._opacity = CGFloat(0.2)
		//
		self._majorThickness = CGFloat(2.0)
		self._minorThickness = CGFloat(1.5)
		self._thickness = CGFloat(1.0)
		//
		self._majorDivisor = 10
		self._minorDivisor = 5
		//
		self._density = CGFloat(10.0)
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphBGView::init(coder) not implemented.")
	}
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// solid fill
			_backgroundColor.setFill()
			context.fill(dirtyRect)
			
			let linePath = NSBezierPath()
			
			// horizontal lines
			for i in 1..<Int(bounds.size.height / _density) {
				if i % _majorDivisor == 0 {
				 _lineColor.withAlphaComponent(_majorOpacity).set()
					linePath.lineWidth = _majorThickness
				} else if i % _minorDivisor == 0 {
					_lineColor.withAlphaComponent(_minorOpacity).set()
					linePath.lineWidth = _minorThickness
				} else {
					_lineColor.withAlphaComponent(_opacity).set()
					linePath.lineWidth = _thickness
				}
				linePath.removeAllPoints()
				linePath.move(to: NSPoint(x: 0, y: CGFloat(i) * _density - 0.5))
				linePath.line(to: NSPoint(x: bounds.size.width, y: CGFloat(i) * _density - 0.5))
				linePath.stroke()
			}
			
			// vertical lines
			for i in 1..<Int(bounds.size.height / _density) {
				if i % _majorDivisor == 0 {
					_lineColor.withAlphaComponent(_majorOpacity).set()
					linePath.lineWidth = _majorThickness
				} else if i % _minorDivisor == 0 {
					_lineColor.withAlphaComponent(_minorOpacity).set()
					linePath.lineWidth = _minorThickness
				} else {
					_lineColor.withAlphaComponent(_opacity).set()
					linePath.lineWidth = _thickness
				}
				linePath.removeAllPoints()
				linePath.move(to: NSPoint(x: CGFloat(i) * _density - 0.5, y: 0))
				linePath.line(to: NSPoint(x: CGFloat(i) * _density - 0.5, y: bounds.size.height))
				linePath.stroke()
			}
			
			context.restoreGState()
		}
	}
}
