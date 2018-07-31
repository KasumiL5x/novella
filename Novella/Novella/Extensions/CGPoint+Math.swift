//
//  CGPoint+Math.swift
//  Novella
//
//  Created by Daniel Green on 08/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public extension CGPoint {
	public init(angle: CGFloat) {
		self.init(x: cos(angle), y: sin(angle))
	}
	
	public func length() -> CGFloat {
		return sqrt(x*x + y*y)
	}
	
	func normalized() -> CGPoint {
		let len = length()
		return len>0 ? self / len : CGPoint.zero
	}
	
	public var angle: CGFloat {
		return atan2(y, x)
	}
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
	return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
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
