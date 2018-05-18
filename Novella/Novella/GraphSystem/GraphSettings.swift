//
//  GraphSettings.swift
//  Novella
//
//  Created by Daniel Green on 18/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class GraphSettings {
	// MARK: - - Nodes -
	class nodes {
		// generic
		static let roundness = CGFloat(10.0)
		static let endColor = NSColor.fromHex("#222222").withAlphaComponent(0.6)
		static let outlineInset = CGFloat(1.0)
		static let outlineColor = NSColor.fromHex("#FAFAF6").withAlphaComponent(0.7)
		static let outlineWidth = CGFloat(1.5)
		static let primedInset = CGFloat(1.0)
		static let primedWidth = CGFloat(1.0)
		static let primedColor = NSColor.fromHex("#B3F865")
		static let selectedInset = CGFloat(1.0)
		static let selectedWidth = CGFloat(3.0)
		static let selectedColor = NSColor.green
		
		// dialog
		static let dialogStartColor = NSColor.fromHex("#A8E6CF").withAlphaComponent(1.0)
		
		// graph
		static let graphStartColor = NSColor.fromHex("#BA78CD").withAlphaComponent(1.0)
	}
}
