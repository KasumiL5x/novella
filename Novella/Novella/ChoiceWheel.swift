//
//  ChoiceWheel.swift
//  novella
//
//  Created by Daniel Green on 04/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class ChoiceSegment {
	var startAngle: CGFloat = 0.0
	var endAngle: CGFloat = 0.0
	var shapeLayer = CAShapeLayer()
	var textLayer = CATextLayer()
	var lineLayer = CAShapeLayer()
}

@IBDesignable
class ChoiceWheel: NSView {
	static let OuterInset: CGFloat = 0.4 // inset from bounds height as a percentage
	static let OuterThickness: CGFloat = 0.3 // thickness of the outer ring as a percentage of the outside radius
	static let BackgroundColor: NSColor = NSColor.fromHex("#3E4048")
	static let Spacing: CGFloat = 2.0
	static let InactiveThicknessModifier: CGFloat = 0.5
	static let InactiveColor: NSColor = NSColor.fromHex("#606470")
	static let ActiveColor: NSColor = NSColor.fromHex("#ff570c")
	
	// MARK: - Variables
	private var _trackingArea: NSTrackingArea?
	private var _activeSegment = -1
	private var _segments: [ChoiceSegment] = []
	private var _bgLayer = CAShapeLayer()
	private var _centerLayer = CAShapeLayer()
	private var _arrowLayer = CAShapeLayer()
	var ClickHandler: ((Int) -> Void)?

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
//		setup(items: [
//			"Segment A",
//			"Segment B",
//			"Segment C",
//			"Segment D"
//		])
	}
	
	// MARK: - Functions
	func setup(items: [String]) {
		_activeSegment = -1
		
		// clear everything
		_segments = []
		_bgLayer = CAShapeLayer()
		_centerLayer = CAShapeLayer()
		_arrowLayer = CAShapeLayer()
		
		// request layers and remove existing ones
		wantsLayer = true
		layer?.sublayers?.removeAll()
		
		createLayers(items: items)
		
		setNeedsDisplay(bounds)
	}
	
	private func createLayers(items: [String]) {
		let center = NSMakePoint(bounds.midX, bounds.midY)
		let radius = (bounds.height - bounds.height * ChoiceWheel.OuterInset) * 0.5
		let insideRadius = radius * ChoiceWheel.OuterThickness
		let outsideRadius = radius - insideRadius * 0.5
		let centerRadius = radius - insideRadius
		
		// bg circle
		let bgPath = NSBezierPath()
		bgPath.appendArc(withCenter: center, radius: outsideRadius, startAngle: 0.0, endAngle: 360.0, clockwise: false)
		_bgLayer.path = bgPath.cgPath
		_bgLayer.fillColor = nil
		_bgLayer.lineWidth = insideRadius
		_bgLayer.strokeColor = ChoiceWheel.BackgroundColor.cgColor
		layer?.addSublayer(_bgLayer)
		
		// center circle
		_centerLayer.path = NSBezierPath(ovalIn: NSMakeRect(
			bounds.midX - centerRadius*0.5,
			bounds.midY - centerRadius*0.5,
			centerRadius,
			centerRadius)
			).cgPath
		_centerLayer.fillColor = ChoiceWheel.BackgroundColor.cgColor
		layer?.addSublayer(_centerLayer)
		
		// arrow
		let arrowWidth = centerRadius * 0.5
		let arrowHeight = centerRadius * 0.5
		_arrowLayer.anchorPoint = NSMakePoint(0.5, 0.0) // must come before origin change
		_arrowLayer.frame.origin = center - NSMakePoint(arrowWidth*0.5, 0.0)
		_arrowLayer.frame.size = NSMakeSize(arrowWidth, centerRadius + arrowHeight)
		let arrowPath = NSBezierPath()
		let arrowOffset = centerRadius*0.4
		arrowPath.move(to: NSPoint(x: 0, y: arrowOffset))
		arrowPath.line(to: NSPoint(x: arrowWidth*0.5, y: arrowOffset+arrowHeight))
		arrowPath.line(to: NSPoint(x: arrowWidth, y: arrowOffset))
		arrowPath.line(to: NSPoint(x: 0, y: arrowOffset))
		arrowPath.close()
		_arrowLayer.path = arrowPath.cgPath
		_arrowLayer.fillColor = ChoiceWheel.BackgroundColor.cgColor
		layer?.addSublayer(_arrowLayer)
		
		// all segments
		let spacing = items.count > 1 ? ChoiceWheel.Spacing : 0.0
		let itemAngle: CGFloat = 360.0 / CGFloat(items.count)
		for idx in 0..<items.count {
			let seg = ChoiceSegment()
			_segments.append(seg)
			
			seg.startAngle = itemAngle * CGFloat(idx) + spacing
			seg.endAngle = seg.startAngle + itemAngle - spacing
			
			// arc layer
			let path = NSBezierPath()
			path.appendArc(withCenter: center, radius: outsideRadius, startAngle: 90.0 - seg.startAngle, endAngle: 90.0 - seg.endAngle, clockwise: true)
			seg.shapeLayer.path = path.cgPath
			seg.shapeLayer.fillColor = nil
			seg.shapeLayer.lineWidth = insideRadius * ChoiceWheel.InactiveThicknessModifier
			seg.shapeLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
			layer?.addSublayer(seg.shapeLayer)
			
			// text layer
			seg.textLayer.string = items[idx]
			seg.textLayer.foregroundColor = ChoiceWheel.InactiveColor.cgColor
			seg.textLayer.fontSize = 14.0
			layer?.addSublayer(seg.textLayer)
			seg.textLayer.frame.size = seg.textLayer.preferredFrameSize()
			// move text into place
			let avgAngle = seg.startAngle + ((seg.endAngle - seg.startAngle) * 0.5)
			let avgDir = CGPoint(angle: toRadians(90.0 - avgAngle)).normalized()
			let textOffset: CGFloat = 25.0
			seg.textLayer.frame.origin = (center + avgDir * outsideRadius) + (avgDir * textOffset)
			// move left half to right anchor
			if avgAngle >= 180.0 {
				seg.textLayer.frame.origin.x -= seg.textLayer.frame.width
			}
			// move bottom half to top anchor
			if avgAngle >= 90.0 && avgAngle <= 270.0 {
				seg.textLayer.frame.origin.y -= seg.textLayer.frame.height
			}
			
			// line layer
			let linePath = NSBezierPath()
			linePath.move(to: center + avgDir * outsideRadius)
			// choose roughly where to go based on 60-degree segments
			if inRange(avgAngle, min: 0.0, max: 60.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.minX, seg.textLayer.frame.minY))
			} else if inRange(avgAngle, min: 60.0, max: 120.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.minX, seg.textLayer.frame.midY))
			} else if inRange(avgAngle, min: 120.0, max: 180.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.minX, seg.textLayer.frame.maxY))
			} else if inRange(avgAngle, min: 180.0, max: 240.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.maxX, seg.textLayer.frame.maxY))
			} else if inRange(avgAngle, min: 240.0, max: 300.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.maxX, seg.textLayer.frame.midY))
			} else if inRange(avgAngle, min: 300.0, max: 360.0, inclusiveMin: true, inclusiveMax: false) {
				linePath.line(to: NSMakePoint(seg.textLayer.frame.maxX, seg.textLayer.frame.minY))
			}
			seg.lineLayer.path = linePath.cgPath
			seg.lineLayer.fillColor = nil
			seg.lineLayer.lineWidth = 2.0
			seg.lineLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
			layer?.addSublayer(seg.lineLayer)
		}
	}
	
	override func prepareForInterfaceBuilder() {
		setup(items: [
			"Segment A",
			"Segment B",
			"Segment C",
			"Segment D"
		])
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
	
	override func mouseMoved(with event: NSEvent) {
		if _segments.isEmpty {
			return
		}
		
		let dir = (event.locationInWindow - NSMakePoint(frame.midX, frame.midY)).normalized()
		var degrees = 90.0 - toDegrees(dir.angle)
		if degrees < 0.0 {
			degrees += 360.0
		}
		
		let radius = (bounds.height - bounds.height * ChoiceWheel.OuterInset) * 0.5
		let insideRadius = radius * ChoiceWheel.OuterThickness
		
		for idx in 0..<_segments.count {
			let segment = _segments[idx]
			if inRange(degrees, min: segment.startAngle, max: segment.endAngle, inclusiveMin: true, inclusiveMax: true) {
				_activeSegment = idx
				segment.shapeLayer.strokeColor = ChoiceWheel.ActiveColor.cgColor
				segment.shapeLayer.lineWidth = insideRadius
				segment.textLayer.foregroundColor = ChoiceWheel.ActiveColor.cgColor
				segment.lineLayer.strokeColor = ChoiceWheel.ActiveColor.cgColor
			} else {
				segment.shapeLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
				segment.shapeLayer.lineWidth = insideRadius * ChoiceWheel.InactiveThicknessModifier
				segment.textLayer.foregroundColor = ChoiceWheel.InactiveColor.cgColor
				segment.lineLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
			}
		}
		
		if _activeSegment != -1 {
			_arrowLayer.fillColor = ChoiceWheel.ActiveColor.cgColor
		}
		CATransaction.begin()
		CATransaction.setAnimationDuration(0.05)
		_arrowLayer.transform = CATransform3DMakeRotation(toRadians(-degrees), 0.0, 0.0, 1.0)
		CATransaction.commit()
	}
	
	override func mouseExited(with event: NSEvent) {
		_activeSegment = -1
		
		let radius = (bounds.height - bounds.height * ChoiceWheel.OuterInset) * 0.5
		let insideRadius = radius * ChoiceWheel.OuterThickness
		
		_segments.forEach { (segment) in
			segment.shapeLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
			segment.shapeLayer.lineWidth = insideRadius * ChoiceWheel.InactiveThicknessModifier
			segment.textLayer.foregroundColor = ChoiceWheel.InactiveColor.cgColor
			segment.lineLayer.strokeColor = ChoiceWheel.InactiveColor.cgColor
		}
		
		_arrowLayer.fillColor = ChoiceWheel.BackgroundColor.cgColor
		_arrowLayer.transform = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0)
		
		setNeedsDisplay(bounds)
	}
	
	override func mouseDown(with event: NSEvent) {
		ClickHandler?(_activeSegment)
	}
	
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
