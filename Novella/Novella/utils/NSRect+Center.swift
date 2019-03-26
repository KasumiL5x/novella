//
//  NSRect+Center.swift
//  novella
//
//  Created by Daniel Green on 17/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSRect {
	public var center: CGPoint {
		return NSMakePoint(origin.x + self.width * 0.5, origin.y + self.height * 0.5)
	}
	
	mutating func setCenter(_ point : CGPoint){
		self.origin = NSMakePoint(point.x - self.width * 0.5, point.y - self.height * 0.5)
	}
}
