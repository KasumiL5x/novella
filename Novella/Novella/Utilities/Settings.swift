//
//  Settings.swift
//  Novella
//
//  Created by Daniel Green on 20/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

struct Settings {
	struct graph {
		static var trashedSaturation: CGFloat = 0.1
		struct nodes {
			static var dialogColor:        NSColor = NSColor.fromHex("#A8E6CF")
			static var graphColor:         NSColor = NSColor.fromHex("#BA78CD")
			static var deliveryColor:      NSColor = NSColor.fromHex("#FFA35F")
			static var contextColor:       NSColor = NSColor.fromHex("#FF5E3A")
		}
	}
}
