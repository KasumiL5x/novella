//
//  NSBezierPath+CGPath.swift
//  novella
//
//  Created by dgreen on 09/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

public struct RectCorner: OptionSet {
	public let rawValue: Int
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	static let minXMinY = RectCorner(rawValue: 1 << 0)
	static let maxXMinY = RectCorner(rawValue: 1 << 1)
	static let maxXMaxY = RectCorner(rawValue: 1 << 2)
	static let minXMaxY = RectCorner(rawValue: 1 << 3)
	static let all = RectCorner(rawValue: ~0)
}
public struct RectEdge: OptionSet {
	public let rawValue: Int
	
	public init(rawValue: Int) {
		self.rawValue = rawValue
	}
	
	static let minX = RectEdge(rawValue: 1 << 0)
	static let maxX = RectEdge(rawValue: 1 << 1)
	static let minY = RectEdge(rawValue: 1 << 2)
	static let maxY = RectEdge(rawValue: 1 << 3)
	static let all = RectEdge(rawValue: ~0)
}

public extension NSBezierPath {
	var cgPath: CGPath {
		let path = CGMutablePath()
		var points = [CGPoint](repeating: .zero, count: 3)
		for i in 0 ..< self.elementCount {
			let type = self.element(at: i, associatedPoints: &points)
			switch type {
			case .moveTo: path.move(to: points[0])
			case .lineTo: path.addLine(to: points[0])
			case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
			case .closePath: path.closeSubpath()
			@unknown default:
				print("Encountered unknown type when converting NSBezierPath to CGPath.")
				continue
			}
		}
		return path
	}
	
	// converted to swift from this lovely source: https://github.com/omnigroup/OmniGroup/blob/master/Frameworks/OmniAppKit/OpenStepExtensions.subproj/NSBezierPath-OAExtensions.m
	class func withRoundedCorners(rect: NSRect, byRoundingCorners corners: RectCorner, withRadius radius: CGFloat, includingEdges edges: RectEdge) -> NSBezierPath {
		// This is the value AppKit uses in -appendBezierPathWithRoundedRect:xRadius:yRadius:
		let kControlPointMultiplier: CGFloat = 0.55228
		
		// empty rect
		if NSIsEmptyRect(rect) {
			return NSBezierPath()
		}
		
		let bezierPath = NSBezierPath()
		var startPoint: NSPoint
		var sourcePoint: NSPoint
		var destPoint: NSPoint
		var controlPoint1: NSPoint
		var controlPoint2: NSPoint
		
		let length = min(NSWidth(rect), NSHeight(rect))
		let radius = min(radius, length / 2.0)
		
		// Top Left (in terms of a non-flipped view)
		var includeCorner = edges.contains(.minX) || edges.contains(.minY)
		if corners.contains(.minXMinY) {
			sourcePoint = NSMakePoint(NSMinX(rect), NSMaxY(rect) - radius)
			startPoint = sourcePoint // capture for "closing" path without necessarily adding a segment for the final edge
			
			destPoint = NSMakePoint(NSMinX(rect) + radius, NSMaxY(rect))
			
			if includeCorner {
				controlPoint1 = sourcePoint
				controlPoint1.y += radius * kControlPointMultiplier
				
				controlPoint2 = destPoint
				controlPoint2.x -= radius * kControlPointMultiplier
				
				bezierPath.move(to: sourcePoint)
				bezierPath.curve(to: destPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)

			} else {
				bezierPath.move(to: destPoint)
			}
		} else {
			startPoint = NSMakePoint(NSMinX(rect), NSMaxY(rect))  // capture for "closing" path without necessarily adding a segment for the final edge
			bezierPath.move(to: startPoint)
		}
		
		// Top right (in terms of a flipped view)
		var includeEdge = edges.contains(.minY)
		includeCorner = edges.contains(.minY) || edges.contains(.maxX)
		if corners.contains(.maxXMinY) {
			sourcePoint = NSMakePoint(NSMaxX(rect) - radius, NSMaxY(rect))
			destPoint = NSMakePoint(NSMaxX(rect), NSMaxY(rect) - radius)
			
			if includeEdge {
				bezierPath.line(to: sourcePoint)
			} else {
				bezierPath.move(to: sourcePoint)
			}
			
			if includeCorner {
				controlPoint1 = sourcePoint
				controlPoint1.x += radius * kControlPointMultiplier
				
				controlPoint2 = destPoint
				controlPoint2.y += radius * kControlPointMultiplier
				
				bezierPath.curve(to: destPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
			} else {
				bezierPath.move(to: destPoint)
			}
		} else {
			destPoint = NSMakePoint(NSMaxX(rect), NSMaxY(rect))
			if includeEdge {
				bezierPath.line(to: destPoint)
			} else {
				bezierPath.move(to: destPoint)
			}
		}
		
		// Bottom right (in terms of a flipped view)
		includeEdge = edges.contains(.maxX)
		includeCorner = edges.contains(.maxX) || edges.contains(.maxY)
		if corners.contains(.maxXMaxY) {
			sourcePoint = NSMakePoint(NSMaxX(rect), NSMinY(rect) + radius)
			destPoint = NSMakePoint(NSMaxX(rect) - radius, NSMinY(rect))
			
			if includeEdge {
				bezierPath.line(to: sourcePoint)
			} else {
				bezierPath.move(to: sourcePoint)
			}
			
			if includeCorner {
				controlPoint1 = sourcePoint
				controlPoint1.y -= radius * kControlPointMultiplier
				
				controlPoint2 = destPoint
				controlPoint2.x += radius * kControlPointMultiplier
				
				bezierPath.curve(to: destPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
			} else {
				bezierPath.move(to: destPoint)
			}
		} else {
			destPoint = NSMakePoint(NSMaxX(rect), NSMinY(rect))
			if includeEdge {
				bezierPath.line(to: destPoint)
			} else {
				bezierPath.move(to: destPoint)
			}
		}
		
		// Bottom left (in terms of a flipped view)
		includeEdge = edges.contains(.maxY)
		includeCorner = edges.contains(.maxY) || edges.contains(.minX)
		if corners.contains(.minXMaxY) {
			sourcePoint = NSMakePoint(NSMinX(rect) + radius, NSMinY(rect))
			destPoint = NSMakePoint(NSMinX(rect), NSMinY(rect) + radius)
			
			if includeEdge {
				bezierPath.line(to: sourcePoint)
			} else {
				bezierPath.move(to: sourcePoint)
			}
			
			if includeCorner {
				controlPoint1 = sourcePoint
				controlPoint1.x -= radius * kControlPointMultiplier
				
				controlPoint2 = destPoint
				controlPoint2.y -= radius * kControlPointMultiplier
				
				bezierPath.curve(to: destPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
			} else {
				bezierPath.move(to: destPoint)
			}
		} else {
			destPoint = NSMakePoint(NSMinX(rect), NSMinY(rect))
			if includeEdge {
				bezierPath.line(to: destPoint)
			} else {
				bezierPath.move(to: destPoint)
			}
		}
		
		// Back to top Left (in terms of a non-flipped view)
		// CONSIDER: If the top-left corner is rounded, the subpath ends at the beginning of the curve rather than at the top-left corner of the bounding rect (assuming non-flipped coordinates). Is that really what we want if using this for composite paths? Should we do an additional move to (MinX, MinY) of the bounding rect?
		includeEdge = edges.contains(.minX)
		if includeEdge {
			bezierPath.line(to: startPoint)
		} else {
			bezierPath.move(to: startPoint)
		}
		
		return bezierPath
	}
}
