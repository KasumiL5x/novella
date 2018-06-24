//
//  CurveHelper.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class CurveHelper {
	enum CurveType {
		case catmullRom
		case square
		case line
	}
	
	static func catmullRom(points: [NSPoint], alpha: CGFloat, closed: Bool, path: NSBezierPath) {
		var points = points // local copy
		
		// supplement 2 points if only start and end provided
		if points.count == 2 {
			let spacing: CGFloat = 20.0
			let start = points[0], end = points[1]
			let diff = fabs(end.x - start.x)
			let gap = diff <= spacing ? diff : spacing // anything below spacing, just use the diff
			
			points.insert(start + NSMakePoint(gap, 0.0), at: 1)
			points.insert(end - NSMakePoint(gap, 0.0), at: 2)
		}
		
		if points.count < 4 {
			return
		}
		
		let endIndex = closed ? points.count : points.count-2
		let startIndex = closed ? 0 : 1
		
		for idx in startIndex..<endIndex {
			let nextIdx = (idx+1) % points.count
			let nextNextIdx = (idx+1) % points.count + 1//(nextIdx+1) % points.count
			let prevIdx = idx-1 < 0 ? points.count-1 : idx-1
			
			let p1 = points[idx]
			let p0 = points[prevIdx]
			let p2 = points[nextIdx]
			let p3 = points[nextNextIdx]
			
			let d1 = (p1 - p0).length()
			let d2 = (p2 - p1).length()
			let d3 = (p3 - p2).length()
			
			var b1: NSPoint
			if fabs(d1) < CGFloat.ulpOfOne {
				b1 = p1
			} else {
				b1 = p2 * pow(d1, 2.0*alpha)
				b1 = b1 - (p0 * pow(d2, 2.0*alpha))
				b1 = b1 + (p1 * (2.0*pow(d1, 2.0*alpha) + 3.0*pow(d1, alpha)*pow(d2, alpha) + pow(d2, 2.0*alpha)))
				b1 = b1 * (1.0 / (3.0*pow(d1, alpha)*(pow(d1, alpha)+pow(d2, alpha))))
			}
			
			var b2: NSPoint
			if fabs(d3) < CGFloat.ulpOfOne {
				b2 = p2
			} else {
				b2 = p1 * pow(d3, 2.0*alpha)
				b2 = b2 - (p3 * pow(d2, 2.0*alpha))
				b2 = b2 + (p2 * (2.0*pow(d3, 2.0*alpha) + 3.0*pow(d3, alpha)*pow(d2, alpha) + pow(d2, 2.0*alpha)))
				b2 = b2 * (1.0 / (3.0*pow(d3, alpha)*(pow(d3, alpha)+pow(d2, alpha))))
			}
			
			if idx == startIndex {
				path.move(to: p0)// only works if p0 instead of p1
			}
			
			// only works if p3 instead of p2
			path.curve(to: p3, controlPoint1: b1, controlPoint2: b2)
		}
		
		if closed {
			path.close()
		}
	}
	
	static func line(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		path.move(to: start)
		path.line(to: end)
	}
	
	static func square(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		let spacing: CGFloat = 20.0
		let diff = end.x - start.x
		
		path.move(to: start)
		
		// on the right side
		if diff > 0.0 {
			let gap = diff <= spacing ? diff : spacing // anything below spacing, just use the diff
			path.line(to: start + NSMakePoint(gap, 0.0))
			path.line(to: NSMakePoint(start.x + gap, end.y))
			path.line(to: end)
		} else {
			let midY = (start.y + end.y) * 0.5
			path.line(to: start + NSMakePoint(spacing, 0.0))
			path.line(to: NSMakePoint(start.x + spacing, midY))
			path.line(to: NSMakePoint(end.x - spacing, midY))
			path.line(to: NSMakePoint(end.x - spacing, end.y))
			path.line(to: end)
		}
	}
}
