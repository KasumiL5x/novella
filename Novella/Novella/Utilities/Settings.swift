//
//  Settings.swift
//  Novella
//
//  Created by Daniel Green on 20/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

struct Settings {
	
	struct keys {
		struct graph {
			static let trashedSaturation = "trashedSaturation"
			
			struct nodes {
				static let roundness = "graph.nodes.roundness"
				static let endColor = "graph.nodes.endColor"
				static let outlineColor = "graph.nodes.outlineColor"
				static let outlineWidth = "graph.nodes.outlineWidth"
				static let primedWidth = "graph.nodes.primedWidth"
				static let primedColor = "graph.nodes.primedColor"
				static let selectedWidth = "graph.nodes.selectedWidth"
				static let selectedColor = "graph.nodes.selectedColor"
				//
				static let dialogStartColor = "graph.nodes.dialogStartColor"
				static let graphStartColor = "graph.nodes.graphStartColor"
				static let deliveryStartColor = "graph.nodes.deliveryStartColor"
				static let contextStartColor = "graph.nodes.contextStartColor"
			}
			
			struct pins {
				static let linkPinColor = "graph.pins.linkPinColor"
				static let linkCurveColor = "graph.pins.linkCurveColor"
				static let branchTrueCurveColor = "graph.pins.branchTrueCurveColor"
				static let branchFalseCurveColor = "graph.pins.branchFalseCurveColor"
			}
		}
	}
	
	struct graph {
		static var trashedSaturation: CGFloat = 0.0
		struct nodes {
			static var roundness:          CGFloat = 10.0
			static var endColor:           NSColor = NSColor.fromHex("#302E2E").withAlphaComponent(0.9)
			static var outlineColor:       NSColor = NSColor.fromHex("#FAFAF6").withAlphaComponent(0.7)
			static var outlineWidth:       CGFloat = 3.5
			static var primedWidth:        CGFloat = 4.5
			static var primedColor:        NSColor = NSColor.fromHex("#B3F865")
			static var selectedWidth:      CGFloat = 5.0
			static var selectedColor:      NSColor = NSColor.green
			static var dialogStartColor:   NSColor = NSColor.fromHex("#A8E6CF")
			static var graphStartColor:    NSColor = NSColor.fromHex("#BA78CD")
			static var deliveryStartColor: NSColor = NSColor.fromHex("#FFA35F")
			static var contextStartColor:  NSColor = NSColor.fromHex("#FF5E3A")
		}
		struct pins {
			static var linkPinColor:          NSColor = NSColor.fromHex("#B3F865")
			static var linkCurveColor:        NSColor = NSColor.fromHex("#B3F865")
			static var branchTrueCurveColor:  NSColor = NSColor.fromHex("#EA772F")
			static var branchFalseCurveColor: NSColor = NSColor.fromHex("#ea482f")
		}
	}
	
	static func resetToApp() {
		// graph
		Settings.graph.trashedSaturation = 0.0
		
		// graph.nodes
		Settings.graph.nodes.roundness = 10.0
		Settings.graph.nodes.endColor = NSColor.fromHex("#302E2E").withAlphaComponent(0.9)
		Settings.graph.nodes.outlineColor = NSColor.fromHex("#FAFAF6").withAlphaComponent(0.7)
		Settings.graph.nodes.outlineWidth = 3.5
		Settings.graph.nodes.primedWidth = 4.5
		Settings.graph.nodes.primedColor = NSColor.fromHex("#B3F865")
		Settings.graph.nodes.selectedWidth = 5.0
		Settings.graph.nodes.selectedColor = NSColor.green
		Settings.graph.nodes.dialogStartColor = NSColor.fromHex("#A8E6CF")
		Settings.graph.nodes.graphStartColor = NSColor.fromHex("#BA78CD")
		Settings.graph.nodes.deliveryStartColor = NSColor.fromHex("#FFA35F")
		Settings.graph.nodes.contextStartColor = NSColor.fromHex("#FF5E3A")
		
		// graph.pins
		Settings.graph.pins.linkPinColor = NSColor.fromHex("#B3F865")
		Settings.graph.pins.linkCurveColor = NSColor.fromHex("#B3F865")
		Settings.graph.pins.branchTrueCurveColor = NSColor.fromHex("#EA772F")
		Settings.graph.pins.branchFalseCurveColor = NSColor.fromHex("#ea482f")
	}
	
	
	static func loadDefaults() {
		// graph
		if hasKey(key: Settings.keys.graph.trashedSaturation) {
			Settings.graph.trashedSaturation = CGFloat(UserDefaults.standard.float(forKey: Settings.keys.graph.trashedSaturation))
		}
		
		// graph.nodes
		if hasKey(key: Settings.keys.graph.nodes.roundness) {
			Settings.graph.nodes.roundness = CGFloat(UserDefaults.standard.float(forKey: Settings.keys.graph.nodes.roundness))
		}
		if hasKey(key: Settings.keys.graph.nodes.endColor) {
			Settings.graph.nodes.endColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.endColor)!
		}

		if hasKey(key: Settings.keys.graph.nodes.outlineColor) {
			Settings.graph.nodes.outlineColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.outlineColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.outlineWidth) {
			Settings.graph.nodes.outlineWidth = CGFloat(UserDefaults.standard.float(forKey: Settings.keys.graph.nodes.outlineWidth))
		}
		if hasKey(key: Settings.keys.graph.nodes.primedWidth) {
			Settings.graph.nodes.primedWidth = CGFloat(UserDefaults.standard.float(forKey: Settings.keys.graph.nodes.primedWidth))
		}
		if hasKey(key: Settings.keys.graph.nodes.primedColor) {
			Settings.graph.nodes.primedColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.primedColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.selectedWidth) {
			Settings.graph.nodes.selectedWidth = CGFloat(UserDefaults.standard.float(forKey: Settings.keys.graph.nodes.selectedWidth))
		}
		if hasKey(key: Settings.keys.graph.nodes.selectedColor) {
			Settings.graph.nodes.selectedColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.selectedColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.dialogStartColor) {
			Settings.graph.nodes.dialogStartColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.dialogStartColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.graphStartColor) {
			Settings.graph.nodes.graphStartColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.graphStartColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.deliveryStartColor) {
			Settings.graph.nodes.deliveryStartColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.deliveryStartColor)!
		}
		if hasKey(key: Settings.keys.graph.nodes.contextStartColor) {
			Settings.graph.nodes.contextStartColor = UserDefaults.standard.color(forKey: Settings.keys.graph.nodes.contextStartColor)!
		}
		
		// graph.pins
		if hasKey(key: Settings.keys.graph.pins.linkPinColor) {
			Settings.graph.pins.linkPinColor = UserDefaults.standard.color(forKey: Settings.keys.graph.pins.linkPinColor)!
		}
		if hasKey(key: Settings.keys.graph.pins.linkCurveColor) {
			Settings.graph.pins.linkCurveColor = UserDefaults.standard.color(forKey: Settings.keys.graph.pins.linkCurveColor)!
		}
		if hasKey(key: Settings.keys.graph.pins.branchTrueCurveColor) {
			Settings.graph.pins.branchTrueCurveColor = UserDefaults.standard.color(forKey: Settings.keys.graph.pins.branchTrueCurveColor)!
		}
		if hasKey(key: Settings.keys.graph.pins.branchFalseCurveColor) {
			Settings.graph.pins.branchFalseCurveColor = UserDefaults.standard.color(forKey: Settings.keys.graph.pins.branchFalseCurveColor)!
		}
	}
	
	static func saveDefaults() {
		// graph
		UserDefaults.standard.set(Settings.graph.trashedSaturation, forKey: Settings.keys.graph.trashedSaturation)
		
		// graph.nodes
		UserDefaults.standard.set(Settings.graph.nodes.roundness, forKey: Settings.keys.graph.nodes.roundness)
		UserDefaults.standard.set(Settings.graph.nodes.endColor, forKey: Settings.keys.graph.nodes.endColor)
		UserDefaults.standard.set(Settings.graph.nodes.outlineColor, forKey: Settings.keys.graph.nodes.outlineColor)
		UserDefaults.standard.set(Settings.graph.nodes.outlineWidth, forKey: Settings.keys.graph.nodes.outlineWidth)
		UserDefaults.standard.set(Settings.graph.nodes.primedWidth, forKey: Settings.keys.graph.nodes.primedWidth)
		UserDefaults.standard.set(Settings.graph.nodes.primedColor, forKey: Settings.keys.graph.nodes.primedColor)
		UserDefaults.standard.set(Settings.graph.nodes.selectedWidth, forKey: Settings.keys.graph.nodes.selectedWidth)
		UserDefaults.standard.set(Settings.graph.nodes.selectedColor, forKey: Settings.keys.graph.nodes.selectedColor)
		UserDefaults.standard.set(Settings.graph.nodes.dialogStartColor, forKey: Settings.keys.graph.nodes.dialogStartColor)
		UserDefaults.standard.set(Settings.graph.nodes.graphStartColor, forKey: Settings.keys.graph.nodes.graphStartColor)
		UserDefaults.standard.set(Settings.graph.nodes.deliveryStartColor, forKey: Settings.keys.graph.nodes.deliveryStartColor)
		UserDefaults.standard.set(Settings.graph.nodes.contextStartColor, forKey: Settings.keys.graph.nodes.contextStartColor)
		
		// graph.pins
		UserDefaults.standard.set(Settings.graph.pins.linkPinColor, forKey: Settings.keys.graph.pins.linkPinColor)
		UserDefaults.standard.set(Settings.graph.pins.linkCurveColor, forKey: Settings.keys.graph.pins.linkCurveColor)
		UserDefaults.standard.set(Settings.graph.pins.branchTrueCurveColor, forKey: Settings.keys.graph.pins.branchTrueCurveColor)
		UserDefaults.standard.set(Settings.graph.pins.branchFalseCurveColor, forKey: Settings.keys.graph.pins.branchFalseCurveColor)
	}
	
	
	static func hasKey(key: String) -> Bool {
		return UserDefaults.standard.object(forKey: key) != nil
	}
}
