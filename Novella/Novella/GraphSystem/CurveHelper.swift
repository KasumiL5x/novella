//
//  CurveHelper.swift
//  Novella
//
//  Created by Daniel Green on 04/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

class CurveHelper {
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
