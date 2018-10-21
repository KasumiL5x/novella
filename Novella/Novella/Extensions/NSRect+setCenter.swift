//
//  NSRect+setCenter.swift
//  novella
//
//  Created by Daniel Green on 04/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSRect {
	mutating func setCenter(_ point : CGPoint){
		self.origin = NSMakePoint(point.x - self.width * 0.5, point.y - self.height * 0.5)
	}
}
