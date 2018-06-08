//
//  CGPoint+Math.swift
//  Novella
//
//  Created by Daniel Green on 08/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
