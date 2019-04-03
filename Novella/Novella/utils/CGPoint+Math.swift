//
//  CGPoint+Math.swift
//  novella
//
//  Created by dgreen on 07/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

public extension CGPoint {
	init(angle: CGFloat) {
		self.init(x: cos(angle), y: sin(angle))
	}
	
	func length() -> CGFloat {
		return sqrt(x*x + y*y)
	}
	
	func normalized() -> CGPoint {
		let len = length()
		return len>0 ? self / len : CGPoint.zero
	}
	
	var angle: CGFloat {
		return atan2(y, x)
	}
	
	func sqrDistance(to: CGPoint) -> CGFloat {
		let dx = (self.x - to.x)
		let dy = (self.y - to.y)
		return (dx * dx) + (dy * dy)
	}
	
	func distance(to: CGPoint) -> CGFloat {
		return sqrt(sqrDistance(to: to))
	}
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
	return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
	return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func * (scalar: CGFloat, point: CGPoint) -> CGPoint {
	return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
	left = left + right
}
