//
//  CurveHelper.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

// https://github.com/seivan/UIBezierPathPort/blob/develop/UIBezierPathPort/NSBezierPathExtension.swift
extension NSBezierPath {
	func quadCurve(to: NSPoint, controlPoint: NSPoint) {
		let QP0 = self.currentPoint
		let CP3 = to
		let CP1 = NSMakePoint(
			//  QP0   +   2   / 3    * (QP1   - QP0  )
			QP0.x + ((2.0 / 3.0) * (controlPoint.x - QP0.x)),
			QP0.y + ((2.0 / 3.0) * (controlPoint.y - QP0.y))
		)
		let CP2 = NSMakePoint(
			//  QP2   +  2   / 3    * (QP1   - QP2)
			to.x + (2.0 / 3.0) * (controlPoint.x - to.x),
			to.y + (2.0 / 3.0) * (controlPoint.y - to.y)
		)
		self.curve(to: CP3, controlPoint1: CP1, controlPoint2: CP2)
	}
}

class CurveHelper {
	enum CurveType {
		case line
		case smooth
		case curve
		case square
		case test
	}

	// https://github.com/jnfisher/ios-curve-interpolation/blob/master/Curve%20Interpolation/UIBezierPath%2BInterpolation.m
	static func hermite(points: [NSPoint], closed: Bool, path: NSBezierPath) {
		if points.count < 2 {
			return
		}
		
		let nCurves = closed ? points.count : points.count-1
		
		for idx in 0..<nCurves {
			var currPoint = points[idx]
			if idx == 0 {
				path.move(to: currPoint)
			}
			
			var nextIdx = (idx+1) % points.count
			var nextPoint = points[nextIdx]
			let endPoint = points[nextIdx]
			var prevIndex = idx-1 < 0 ? points.count-1 : idx-1
			var prevPoint = points[prevIndex]
			
			var mx: CGFloat, my: CGFloat
			if closed || idx > 0 {
				mx = (nextPoint.x - currPoint.x)*0.5 + (currPoint.x - prevPoint.x)*0.5
				my = (nextPoint.y - currPoint.y)*0.5 + (currPoint.y - prevPoint.y)*0.5
			} else {
				mx = (nextPoint.x - currPoint.x)*0.5;
				my = (nextPoint.y - currPoint.y)*0.5;
			}
			
			let ctrlPoint1 = NSMakePoint(currPoint.x + mx / 3.0, currPoint.y + my / 3.0)
			
			currPoint = points[nextIdx]
			
			nextIdx = (nextIdx+1) % points.count;
			prevIndex = idx
			
			prevPoint = points[prevIndex]
			nextPoint = points[nextIdx]
			
			if closed || idx < nCurves-1 {
				mx = (nextPoint.x - currPoint.x)*0.5 + (currPoint.x - prevPoint.x)*0.5
				my = (nextPoint.y - currPoint.y)*0.5 + (currPoint.y - prevPoint.y)*0.5
			} else {
				mx = (currPoint.x - prevPoint.x)*0.5
				my = (currPoint.y - prevPoint.y)*0.5
			}
			
			let ctrlPoint2 = NSMakePoint(currPoint.x - mx / 3.0, currPoint.y - my / 3.0)
			
			path.curve(to: endPoint, controlPoint1: ctrlPoint1, controlPoint2: ctrlPoint2)
		}
		
		if closed {
			path.close()
		}
	}
	
	static func test(points: [NSPoint], tension: CGFloat, path: NSBezierPath) {
		if points.count < 2 {
			return
		}
		
		var p1 = points[0]
		path.move(to: p1)
		
		if points.count == 2 {
			path.line(to: points[1])
			return
		}
		
		for i in 1..<points.count {
			let p2 = points[i]
			let mid = midPoint(p1: p1, p2: p2)
			
			path.quadCurve(to: mid, controlPoint: controlPointFor(p1: mid, p2: p1))
			path.quadCurve(to: p2, controlPoint: controlPointFor(p1: mid, p2: p2))
			
			p1 = p2
		}
		
//		var derivatives: [NSPoint] = []
//		for i in 0..<points.count {
//			let prev = points[max(i-1, 0)]
//			let next = points[min(i+1, points.count-1)]
//			derivatives.append((next - prev) * tension)
//		}
//
//		for i in 0..<points.count {
//			if 0 == i {
//				path.move(to: points[0])
//			} else {
//				let endPoint = points[i]
//				let cp1 = points[i-1] + (derivatives[i-1] * tension)
//				let cp2 = points[i] - (derivatives[i] * tension)
//
//				path.curve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
//			}
//		}
	}
	static func midPoint(p1: NSPoint, p2: NSPoint) -> NSPoint {
		return (p1 + p2) * 0.5
	}
	static func controlPointFor(p1: NSPoint, p2: NSPoint) -> NSPoint {
		var mid = midPoint(p1: p1, p2: p2)
		let diff = fabs(p2.y - mid.y)
		
		if p1.y < p2.y {
			mid.y += diff
		} else if p1.y > p2.y {
			mid.y -= diff
		}
		
		return mid
	}
	
	static func line(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		path.move(to: start)
		path.line(to: end)
	}
	
	static func smooth(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		let a = start
		let d = end
		let b = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: a.y)
		let c = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: d.y)
		path.move(to: a)
		path.curve(to: d, controlPoint1: b, controlPoint2: c)
	}
	static func smoothOffset(start: NSPoint, end: NSPoint, path: NSBezierPath, offset: NSPoint) {
		let a = start
		let d = end
		let b = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: a.y) + offset
		let c = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: d.y) + offset
		path.move(to: a)
		path.curve(to: d, controlPoint1: b, controlPoint2: c)
	}
	
	static func curve(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		let offset = abs(start.x - end.x)  * 0.75
		let cp1 = NSPoint(x: end.x - offset, y: start.y)
		let cp2 = NSPoint(x: start.x + offset, y: end.y)
		path.move(to: start)
		path.curve(to: end, controlPoint1: cp1, controlPoint2: cp2)
	}
	
	static func square(start: NSPoint, end: NSPoint, path: NSBezierPath) {
		let a = start
		let d = end
		let b = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: a.y)
		let c = NSPoint(x: a.x + (d.x - a.x) * 0.5, y: d.y)
		path.move(to: a)
		path.line(to: b)
		path.move(to: b)
		path.line(to: c)
		path.move(to: c)
		path.line(to: d)
	}
}
