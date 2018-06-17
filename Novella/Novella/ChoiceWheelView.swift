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
	@IBInspectable var _itemCount: Int = 3
	private var _activeItem: Int = -1
	private var _spacing: CGFloat = 10.0
	private var _trackingArea: NSTrackingArea?
	
	// MARK: - Functions -
	func setup(count: Int) {
		_itemCount = count
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
		let dir = (event.locationInWindow - NSMakePoint(frame.midX, frame.midY)).normalized()
		var degrees = 90.0 - toDegrees(dir.angle)
		if degrees < 0.0 {
			degrees += 360.0
		}
		
		let itemAngle: CGFloat = 360.0 / CGFloat(_itemCount)
		for idx in 0..<_itemCount {
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
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let colors: [NSColor] = [
				NSColor.fromHex("#6c567b"),
				NSColor.fromHex("#c06c84"),
				NSColor.fromHex("#f67280"),
				NSColor.fromHex("#f8b195"),
				NSColor.fromHex("#ff00ff")
			]
			
			let center = NSMakePoint(bounds.midX, bounds.midY)
			let radius: CGFloat = 50.0
			let itemAngle: CGFloat = 360.0 / CGFloat(_itemCount)
			for idx in 0..<_itemCount {
				let startAngle = itemAngle * CGFloat(idx) + _spacing
				let endAngle = startAngle + itemAngle - _spacing

				// draw ring segment
				context.beginPath()
				context.addArc(center: center, radius: radius, startAngle: toRadians(90.0 - startAngle), endAngle: toRadians(90.0 - endAngle), clockwise: true)
				colors[idx % colors.count].setStroke()
				if _activeItem == idx {
					context.setLineWidth(15.0)
				} else {
					context.setLineWidth(10.0)
				}
				context.strokePath()
				
				// draw angle line
				let centerAngle = startAngle + ((endAngle - startAngle)/2)
				let angleDir = CGPoint(angle: toRadians(90.0-centerAngle))
				let lineStart = center + angleDir * radius
				let lineEnd = lineStart + angleDir * 25.0
				context.setLineWidth(1.5)
				context.move(to: lineStart)
				context.addLine(to: lineEnd)
//				let underlineEnd = lineEnd + NSMakePoint(centerAngle > 180.0 ? -100.0	: 100.0, 0.0)
//				context.addLine(to: underlineEnd)
				context.strokePath()
			}
			
			context.restoreGState()
		}
	}
	
	// MARK: - Helpers -
	private func toRadians(_ degrees: CGFloat) -> CGFloat {
		return degrees * 0.0174533
	}
	
	private func toDegrees(_ radians: CGFloat) -> CGFloat {
		return radians * 57.2958
	}
}
