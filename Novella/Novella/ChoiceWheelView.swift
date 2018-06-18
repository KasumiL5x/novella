//
//  ChoiceWheelView.swift
//  Novella
//
//  Created by Daniel Green on 17/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class ChoiceSegment {
	var startAngle: CGFloat = 0.0
	var endAngle: CGFloat = 0.0
	var shapeLayer: CAShapeLayer = CAShapeLayer()
	var textLayer: CATextLayer = CATextLayer()
	var lineLayer: CAShapeLayer = CAShapeLayer()
}

@IBDesignable
class ChoiceWheelView: NSView {
	// MARK: Statics
	static let BackgroundColor: NSColor = NSColor.fromHex("#3E4048")
	static let InactiveColor: NSColor = NSColor.fromHex("#606470")
	static let ActiveColor: NSColor = NSColor.fromHex("#ff570c")
	static let Thickness: CGFloat = 20.0
	static let InactiveThicknessModifier: CGFloat = 0.5
	static let Radius: CGFloat = 50.0
	static let Spacing: CGFloat = 2.0
	static let CenterRadius: CGFloat = 30.0
	
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
	private var _trackingArea: NSTrackingArea?
	
	private var _segments: [ChoiceSegment] = []
	private var _backgroundLayer: CAShapeLayer = CAShapeLayer()
	private var _centerLayer: CAShapeLayer = CAShapeLayer()
	private var _arrowLayer: CAShapeLayer = CAShapeLayer()
	
	// MARK: - Functions -
	func setup(options: [String]) {
//		_items = options
		setNeedsDisplay(bounds)
		
		createLayers()
	}
	
	private func createLayers() {
		wantsLayer = true
		layer?.sublayers?.removeAll()
		
		let center = NSMakePoint(bounds.midX, bounds.midY)
		
		// background circle
		let backgroundPath = NSBezierPath()
		backgroundPath.appendArc(withCenter: center, radius: ChoiceWheelView.Radius, startAngle: 0.0, endAngle: 360.0, clockwise: false)
		_backgroundLayer.path = backgroundPath.cgPath
		_backgroundLayer.fillColor = nil
		_backgroundLayer.lineWidth = ChoiceWheelView.Thickness
		_backgroundLayer.strokeColor = ChoiceWheelView.BackgroundColor.cgColor
		layer?.addSublayer(_backgroundLayer)
		
		// center circle
		_centerLayer.path = NSBezierPath(ovalIn: NSMakeRect(
			bounds.midX - ChoiceWheelView.CenterRadius*0.5,
			bounds.midY - ChoiceWheelView.CenterRadius*0.5,
			ChoiceWheelView.CenterRadius,
			ChoiceWheelView.CenterRadius)
		).cgPath
		_centerLayer.fillColor = ChoiceWheelView.BackgroundColor.cgColor
		layer?.addSublayer(_centerLayer)
		
		// all items
		let itemAngle: CGFloat = 360.0 / CGFloat(_items.count)
		for idx in 0..<_items.count {
			let segment = ChoiceSegment()
			_segments.append(segment)
			
			segment.startAngle = itemAngle * CGFloat(idx) + ChoiceWheelView.Spacing
			segment.endAngle = segment.startAngle + itemAngle - ChoiceWheelView.Spacing
			
			// arc layer
			let path = NSBezierPath()
			path.appendArc(withCenter: center, radius: ChoiceWheelView.Radius, startAngle: 90.0 - segment.startAngle, endAngle: 90.0 - segment.endAngle, clockwise: true)
			segment.shapeLayer.path = path.cgPath
			segment.shapeLayer.fillColor = nil
			segment.shapeLayer.lineWidth = ChoiceWheelView.Thickness * ChoiceWheelView.InactiveThicknessModifier
			segment.shapeLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
			layer?.addSublayer(segment.shapeLayer)
			
			// text layer
			segment.textLayer.string = _items[idx]
			segment.textLayer.foregroundColor = ChoiceWheelView.InactiveColor.cgColor
			segment.textLayer.fontSize = 14.0
			layer?.addSublayer(segment.textLayer)
			segment.textLayer.frame.size = segment.textLayer.preferredFrameSize()
			// move text into place
			let avgAngle = segment.startAngle + ((segment.endAngle - segment.startAngle) * 0.5)
			let avgDir = CGPoint(angle: toRadians(90.0 - avgAngle))
			let textOffset: CGFloat = 25.0
			segment.textLayer.frame.origin = (center + avgDir * ChoiceWheelView.Radius) + (avgDir * textOffset)
			// move left half to right anchor
			if avgAngle > 180.0 {
				segment.textLayer.frame.origin.x -= segment.textLayer.frame.width
			}
			// move bottom half to top anchor
			if avgAngle >= 90.0 && avgAngle <= 270.0 {
				segment.textLayer.frame.origin.y -= segment.textLayer.frame.height
			}
			
			// line layer
			let linePath = NSBezierPath()
			linePath.move(to: center + avgDir * ChoiceWheelView.Radius)
			// choose roughly where to go based on 60-degree segments
			if inRange(avgAngle, min: 0.0, max: 60.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.minX, segment.textLayer.frame.minY))
			} else if inRange(avgAngle, min: 60.0, max: 120.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.minX, segment.textLayer.frame.midY))
			} else if inRange(avgAngle, min: 120.0, max: 180.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.minX, segment.textLayer.frame.maxY))
			} else if inRange(avgAngle, min: 180.0, max: 240.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.maxX, segment.textLayer.frame.maxY))
			} else if inRange(avgAngle, min: 240.0, max: 300.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.maxX, segment.textLayer.frame.midY))
			} else if inRange(avgAngle, min: 300.0, max: 360.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(segment.textLayer.frame.maxX, segment.textLayer.frame.minY))
			}
			segment.lineLayer.path = linePath.cgPath
			segment.lineLayer.fillColor = nil
			segment.lineLayer.lineWidth = 2.0
			segment.lineLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
			layer?.addSublayer(segment.lineLayer)
		}
	
		// arrow
		let arrowWidth = ChoiceWheelView.CenterRadius * 0.5
		let arrowHeight = ChoiceWheelView.CenterRadius * 0.5
		_arrowLayer.anchorPoint = NSMakePoint(0.5, 0.0) // must come before origin change
		_arrowLayer.frame.origin = center - NSMakePoint(arrowWidth*0.5, 0.0)
		_arrowLayer.frame.size = NSMakeSize(arrowWidth, ChoiceWheelView.CenterRadius + arrowHeight)
		let arrowPath = NSBezierPath()
		let arrowOffset = ChoiceWheelView.CenterRadius*0.4
		arrowPath.move(to: NSPoint(x: 0, y: arrowOffset))
		arrowPath.line(to: NSPoint(x: arrowWidth*0.5, y: arrowOffset+arrowHeight))
		arrowPath.line(to: NSPoint(x: arrowWidth, y: arrowOffset))
		arrowPath.line(to: NSPoint(x: 0, y: arrowOffset))
		arrowPath.close()
		_arrowLayer.path = arrowPath.cgPath
		_arrowLayer.fillColor = ChoiceWheelView.BackgroundColor.cgColor
		layer?.addSublayer(_arrowLayer)
	}
	
	override func prepareForInterfaceBuilder() {
		createLayers()
		print("TODO: Delete this function.")
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
		
		_segments.forEach { (segment) in
			segment.shapeLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
			segment.shapeLayer.lineWidth = ChoiceWheelView.Thickness * ChoiceWheelView.InactiveThicknessModifier
			segment.textLayer.foregroundColor = ChoiceWheelView.InactiveColor.cgColor
			segment.lineLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
		}
		
		_arrowLayer.fillColor = ChoiceWheelView.BackgroundColor.cgColor
		_arrowLayer.transform = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
		
		setNeedsDisplay(bounds)
	}
	
	override func mouseMoved(with event: NSEvent) {
		if _items.isEmpty {
			return
		}
		
		let dir = (event.locationInWindow - NSMakePoint(frame.midX, frame.midY)).normalized()
		var degrees = 90.0 - toDegrees(dir.angle)
		if degrees < 0.0 {
			degrees += 360.0
		}
		
		for idx in 0..<_segments.count {
			let segment = _segments[idx]
			if inRange(degrees, min: segment.startAngle, max: segment.endAngle, inclusiveMin: true, inclusiveMax: true) {
				_activeItem = idx
				segment.shapeLayer.strokeColor = ChoiceWheelView.ActiveColor.cgColor
				segment.shapeLayer.lineWidth = ChoiceWheelView.Thickness
				segment.textLayer.foregroundColor = ChoiceWheelView.ActiveColor.cgColor
				segment.lineLayer.strokeColor = ChoiceWheelView.ActiveColor.cgColor
			} else {
				segment.shapeLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
				segment.shapeLayer.lineWidth = ChoiceWheelView.Thickness * ChoiceWheelView.InactiveThicknessModifier
				segment.textLayer.foregroundColor = ChoiceWheelView.InactiveColor.cgColor
				segment.lineLayer.strokeColor = ChoiceWheelView.InactiveColor.cgColor
			}
		}
		
		if _activeItem != -1 {
			_arrowLayer.fillColor = ChoiceWheelView.ActiveColor.cgColor
		}
		_arrowLayer.transform = CATransform3DMakeRotation(toRadians(-degrees), 0.0, 0.0, 1.0)
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
