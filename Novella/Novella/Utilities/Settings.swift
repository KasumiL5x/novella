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
		static var trashedColorLight = NSColor.fromHex("#E0E0E0")
		static var trashedColorDark = NSColor.fromHex("#CCCCCC")
		struct nodes {
			static var dialogColor:        NSColor = NSColor.fromHex("#A8E6CF")
			static var graphColor:         NSColor = NSColor.fromHex("#BA78CD")
			static var deliveryColor:      NSColor = NSColor.fromHex("#FFA35F")
			static var contextColor:       NSColor = NSColor.fromHex("#FF5E3A")
		}
	}
}
