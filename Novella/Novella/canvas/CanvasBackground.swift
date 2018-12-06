//
//  CanvasBackground.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasBackground: NSView {
	// color
	private var _backgroundColor: NSColor
	private var _lineColor: NSColor
	// opacity
	private var _majorOpacity: CGFloat
	private var _minorOpacity: CGFloat
	private var _opacity: CGFloat
	// thickness
	private var _majorThickness: CGFloat
	private var _minorThickness: CGFloat
	private var _thickness: CGFloat
	// divisors
	private var _primaryDivisor: Int
	private var _secondaryDivisor: Int
	private var _tertiaryDivisor: Int
	// depth
	private var _density: CGFloat
	
	override init(frame frameRect: NSRect) {
		self._backgroundColor = NSColor.fromHex("#dfedff")
		self._lineColor = NSColor.fromHex("#acd3ff")
		//
		self._majorOpacity = CGFloat(0.5)
		self._minorOpacity = CGFloat(0.4)
		self._opacity = CGFloat(0.2)
		//
		self._majorThickness = CGFloat(1.5)
		self._minorThickness = CGFloat(1.0)
		self._thickness = CGFloat(0.5)
		//
		self._primaryDivisor = 64
		self._secondaryDivisor = 32
		self._tertiaryDivisor = 16
		//
		self._density = CGFloat(10.0)
		
		super.init(frame: frameRect)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
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
			for i in stride(from: Int(dirtyRect.minY), through: Int(dirtyRect.maxY), by: 1) {
				if i % _primaryDivisor == 0 {
					_lineColor.withAlphaComponent(_majorOpacity).set()
					linePath.lineWidth = _majorThickness
				} else if i % _secondaryDivisor == 0 {
					_lineColor.withAlphaComponent(_minorOpacity).set()
					linePath.lineWidth = _minorThickness
				} else if i % _tertiaryDivisor == 0 {
					_lineColor.withAlphaComponent(_opacity).set()
					linePath.lineWidth = _thickness
				} else {
					continue
				}
				
				let asFloat = CGFloat(i)
				linePath.removeAllPoints()
				linePath.move(to: NSMakePoint(dirtyRect.minX, asFloat))
				linePath.line(to: NSMakePoint(dirtyRect.maxX, asFloat))
				linePath.stroke()
			}
			
			// vertical lines
			for i in stride(from: Int(dirtyRect.minX), through: Int(dirtyRect.maxX), by: 1) {
				if i % _primaryDivisor == 0 {
					_lineColor.withAlphaComponent(_majorOpacity).set()
					linePath.lineWidth = _majorThickness
				} else if i % _secondaryDivisor == 0 {
					_lineColor.withAlphaComponent(_minorOpacity).set()
					linePath.lineWidth = _minorThickness
				} else if i % _tertiaryDivisor == 0 {
					_lineColor.withAlphaComponent(_opacity).set()
					linePath.lineWidth = _thickness
				} else {
					continue
				}
				
				let asFloat = CGFloat(i)
				linePath.removeAllPoints()
				linePath.move(to: NSMakePoint(asFloat, dirtyRect.minY))
				linePath.line(to: NSMakePoint(asFloat, dirtyRect.maxY))
				linePath.stroke()
			}
			
			context.restoreGState()
		}
	}
}
