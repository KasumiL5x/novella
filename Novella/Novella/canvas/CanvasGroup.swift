//
//  CanvasGroup.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasGroup: CanvasObject {
	static let Roundness: CGFloat = 0.075
	static let NormalOutlineSize: CGFloat = 1.0
	static let PrimedOutlineSize: CGFloat = 2.0
	static let SelectedOutlineSize: CGFloat = 4.0
	static let FlagSize: CGFloat = 0.3
	
	let Group: NVGroup
	
	private let _outlineLayer: CAShapeLayer
	
	init(canvas: Canvas, group: NVGroup) {
		self.Group = group
		self._outlineLayer = CAShapeLayer()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1))
		self.frame = objectRect()
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		let mainFrame = objectRect()
		
		// main background layer
		let bgGradient = CAGradientLayer()
		bgGradient.frame = mainFrame
		bgGradient.cornerRadius = (max(bgGradient.frame.width, bgGradient.frame.height) * 0.5) * CanvasGroup.Roundness
		bgGradient.colors = [NSColor.fromHex("#A6BBCF").cgColor, NSColor.fromHex("#b3c5d6").cgColor]
		bgGradient.startPoint = NSPoint.zero
		bgGradient.endPoint = NSMakePoint(0.0, 1.0)
		bgGradient.locations = [0.0, 0.3]
		// outline layer
		_outlineLayer.fillColor = nil
		_outlineLayer.path = NSBezierPath(roundedRect: bgGradient.frame, xRadius: bgGradient.cornerRadius, yRadius: bgGradient.cornerRadius).cgPath
		_outlineLayer.strokeColor = NSColor.fromHex("#b3c5d6").withAlphaComponent(0.4).cgColor //99b1c8
		setupOutlineLayer()
		layer?.addSublayer(_outlineLayer) // add before bg so it's below it
		layer?.addSublayer(bgGradient)
		
		// flag layer
		let flagLayer = CAShapeLayer()
		let flagRect = NSMakeRect(0, 0, mainFrame.width * CanvasGroup.FlagSize, mainFrame.height)
		flagLayer.path = NSBezierPath.withRoundedCorners(rect: flagRect, byRoundingCorners: [.minXMinY, .minXMaxY], withRadius: bgGradient.cornerRadius, includingEdges: [.all]).cgPath
		flagLayer.fillColor = NSColor.fromHex("#99b1c8").cgColor
		layer?.addSublayer(flagLayer)
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasGroup.onSubmerge), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	@objc private func onSubmerge() {
		_canvas.setupFor(group: self.Group)
	}
	
	private func setupOutlineLayer() {
		let width: CGFloat
		switch CurrentState {
		case .normal:
			width = CanvasGroup.NormalOutlineSize
		case .primed:
			width = CanvasGroup.PrimedOutlineSize
		case .selected:
			width = CanvasGroup.SelectedOutlineSize
		}
		_outlineLayer.lineWidth = width
	}
	
	// virtuals
	override func mainColor() -> NSColor {
		return NSColor.fromHex("#FF00FF") // not yet implemented this class fully
	}
	override func onMove() {
		_canvas.Doc.Positions[Group.UUID] = frame.origin
	}
	override func onStateChanged() {
		setupOutlineLayer()
	}
	override func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 100.0, 100.0 * 0.25)
	}
}
