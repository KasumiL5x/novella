//
//  ChoiceWheelView.swift
//  Novella
//
//  Created by Daniel Green on 17/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

@IBDesignable
class ChoiceWheelView: NSView {
	// MARK: - Variables -
	private var _items: [String] = [
		"This is the preview of segment A.",
		"This is the preview of segment B.",
		"This is the preview of segment C.",
		"This is the preview of segment D.",
		"This is the preview of segment E.",
		"This is the preview of segment F."
	]
//	@IBInspectable var _itemCount: Int = 3
	private var _activeItem: Int = 0
	private var _spacing: CGFloat = 2.0
	private var _trackingArea: NSTrackingArea?
	
	// MARK: - Functions -
	func setup(options: [String]) {
//		_items = options
//		_itemCount = options.count
		setNeedsDisplay(bounds)
	}
	
	override func updateTrackingAreas() {
		if _trackingArea != nil {
			self.removeTrackingArea(_trackingArea!)
		}
		
		let options: NSTrackingArea.Options = [
			NSTrackingArea.Options.activeInKeyWindow,
			NSTrackingArea.Options.mouseMoved,
			NSTrackingArea.Options.mouseEnteredAndExited
		]
		_trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(_trackingArea!)
	}
	
	override func mouseExited(with event: NSEvent) {
		_activeItem = -1
		setNeedsDisplay(bounds)
	}
	
	override func mouseMoved(with event: NSEvent) {
		if _items.isEmpty {
			_activeItem = -1
			setNeedsDisplay(bounds)
			return
		}
		
		let dir = (event.locationInWindow - NSMakePoint(frame.midX, frame.midY)).normalized()
		var degrees = 90.0 - toDegrees(dir.angle)
		if degrees < 0.0 {
			degrees += 360.0
		}
		
		let itemAngle: CGFloat = 360.0 / CGFloat(_items.count)
		for idx in 0..<_items.count {
			let startAngle = itemAngle * CGFloat(idx) + _spacing
			let endAngle = startAngle + itemAngle - _spacing
			
			if degrees >= startAngle && degrees <= endAngle {
				_activeItem = idx
				setNeedsDisplay(bounds)
				break
			}
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if _items.isEmpty {
			return
		}
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()

			// draw background
			let center = NSMakePoint(bounds.midX, bounds.midY)
			let radius: CGFloat = 50.0
			let width: CGFloat = 20.0
			context.beginPath()
			context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: toRadians(360.0), clockwise: true)
			NSColor.fromHex("#3E4048").setStroke()
			context.setLineWidth(width)
			context.strokePath()
			
			// draw items and labels
			let itemAngle: CGFloat = 360.0 / CGFloat(_items.count)
			for idx in 0..<_items.count {
				let startAngle = itemAngle * CGFloat(idx) + _spacing
				let endAngle = startAngle + itemAngle - (_spacing*2)
				
				// draw segment arc
				context.beginPath()
				context.addArc(center: center, radius: radius, startAngle: toRadians(90.0 - startAngle), endAngle: toRadians(90.0 - endAngle), clockwise: true)
				if _activeItem == idx {
					context.setLineWidth(width)
					NSColor.fromHex("#ff570c").setStroke()
				} else {
					NSColor.fromHex("#606470").setStroke()
					context.setLineWidth(width*0.5)
				}
				context.strokePath()
				
				// calculate text rectangle
				let maxWidth: CGFloat = 500.0
				let textOptions: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
				let textAttrs = [
					NSAttributedStringKey.foregroundColor: (_activeItem != idx) ? NSColor.black : NSColor.fromHex("#ff570c")
				]
				let asString = NSString(string: _items[idx])
				var textRect = asString.boundingRect(with: NSMakeSize(maxWidth, CGFloat.infinity), options: textOptions, attributes: textAttrs, context: nil)
				// move text outside of the ring
				let avgAngle = startAngle + ((endAngle - startAngle) / 2)
				let avgDir = CGPoint(angle: toRadians(90.0 - avgAngle))
				let textOffset: CGFloat = 25.0
				textRect.origin = (center + avgDir * radius) + (avgDir * textOffset)
				// move left half to right anchor
				if avgAngle > 180.0 {
					textRect.origin.x -= textRect.width
				}
				// move bottom half to top anchor
				if avgAngle > 90.0 && avgAngle < 270.0 {
					textRect.origin.y -= textRect.height
				}
				
				// draw line for text from arc segments
				let lineStart = (center + avgDir * radius)
				context.move(to: lineStart)
				// choose roughly where to go based on 60-degree segments
				if inRange(avgAngle, min: 0.0, max: 60.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.minX, textRect.minY))
				} else if inRange(avgAngle, min: 60.0, max: 120.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.minX, textRect.midY))
				} else if inRange(avgAngle, min: 120.0, max: 180.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.minX, textRect.maxY))
				} else if inRange(avgAngle, min: 180.0, max: 240.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.maxX, textRect.maxY))
				} else if inRange(avgAngle, min: 240.0, max: 300.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.maxX, textRect.midY))
				} else if inRange(avgAngle, min: 300.0, max: 360.0, inclusiveMin: true, inclusiveMax: false) {
					context.addLine(to: NSMakePoint(textRect.maxX, textRect.minY))
				}
				context.setLineWidth(2.0)
				context.strokePath()
				
				// draw text
				asString.draw(with: textRect, options: textOptions, attributes: textAttrs, context: nil)
			}
			
//			let itemAngle: CGFloat = 360.0 / CGFloat(_items.count)
//			for idx in 0..<_items.count {
//				let startAngle = itemAngle * CGFloat(idx) + _spacing
//				let endAngle = startAngle + itemAngle - _spacing
//
//				// draw ring segment
//				context.beginPath()
//				context.addArc(center: center, radius: radius, startAngle: toRadians(90.0 - startAngle), endAngle: toRadians(90.0 - endAngle), clockwise: true)
//				colors[idx % colors.count].setStroke()
//				if _activeItem == idx {
//					context.setLineWidth(15.0)
//				} else {
//					context.setLineWidth(10.0)
//				}
//				context.strokePath()
//
//				// calculate rect of text
//				let textDrawingOptions: NSString.DrawingOptions = [
//					NSString.DrawingOptions.usesLineFragmentOrigin,
//					NSString.DrawingOptions.usesFontLeading
//				]
//				let asNSString = NSString(string: _items[idx])
//				var textRect = asNSString.boundingRect(
//					with: NSMakeSize(500.0, CGFloat.infinity),
//					options: textDrawingOptions,
//					attributes: nil,
//					context: nil
//				)
//				let centerAngle = startAngle + ((endAngle - startAngle)/2)
//				let angleDir = CGPoint(angle: toRadians(90.0-centerAngle))
//				textRect.origin = (center + angleDir * radius) + (angleDir * 25.0)
//				if centerAngle > 180.0 {
//					textRect.origin.x -= textRect.width + 2.0
//				} else {
//					textRect.origin.x += 2.0
//				}
//
//				// line around text
//				context.move(to: center + angleDir * radius)
//				if centerAngle > 180.0 {
//					context.addLine(to: NSMakePoint(textRect.maxX, textRect.minY))
//					context.addLine(to: NSMakePoint(textRect.minX, textRect.minY))
//				} else {
//					context.addLine(to: NSMakePoint(textRect.minX, textRect.minY))
//					context.addLine(to: NSMakePoint(textRect.maxX, textRect.minY))
//				}
//				context.setLineWidth(1.5)
//				context.strokePath()
//
//				// draw text
//				asNSString.draw(with: textRect, options: textDrawingOptions, attributes: nil, context: nil)
//			}
			
			context.restoreGState()
		}
	}
	
	// MARK: - Helpers -
	private func inRange(_ value: CGFloat, min: CGFloat, max: CGFloat, inclusiveMin: Bool, inclusiveMax: Bool) -> Bool {
		let aboveMin = inclusiveMin ? (value >= min) : (value > min)
		let belowMax = inclusiveMax ? (value <= max) : (value < max)
		return aboveMin && belowMax
	}
	private func toRadians(_ degrees: CGFloat) -> CGFloat {
		return degrees * 0.0174533
	}
	
	private func toDegrees(_ radians: CGFloat) -> CGFloat {
		return radians * 57.2958
	}
}
