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
	static let IconSize: CGFloat = 0.55
	static let LabelOffset: CGFloat = 4.0
	
	let Group: NVGroup
	
	private let _outlineLayer: CAShapeLayer
	private let _labelLayer: CATextLayer
	
	init(canvas: Canvas, group: NVGroup) {
		self.Group = group
		self._outlineLayer = CAShapeLayer()
		self._labelLayer = CATextLayer()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1))
		self.frame = objectRect()
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		let mainFrame = objectRect()
		
		let flagColor = NSColor.fromHex("#99b1c8") //99b1c8
		let primaryColor = flagColor.lighter(removeSaturation: 0.15) // also #A6BBCF
		let darkerColor = primaryColor.darker(removeValue: 0.04) // also b3c5d6
		
		// main background layer
		let bgGradient = CAGradientLayer()
		bgGradient.frame = mainFrame
		bgGradient.cornerRadius = (max(bgGradient.frame.width, bgGradient.frame.height) * 0.5) * CanvasGroup.Roundness
		bgGradient.colors = [primaryColor.cgColor, darkerColor.cgColor]
		bgGradient.startPoint = NSPoint.zero
		bgGradient.endPoint = NSMakePoint(0.0, 1.0)
		bgGradient.locations = [0.0, 0.3]
		// outline layer
		_outlineLayer.fillColor = nil
		_outlineLayer.path = NSBezierPath(roundedRect: bgGradient.frame, xRadius: bgGradient.cornerRadius, yRadius: bgGradient.cornerRadius).cgPath
		_outlineLayer.strokeColor = darkerColor.withAlphaComponent(0.4).cgColor //99b1c8
		setupOutlineLayer()
		layer?.addSublayer(_outlineLayer) // add before bg so it's below it
		layer?.addSublayer(bgGradient)
		
		// flag layer
		let flagLayer = CAShapeLayer()
		let flagRect = NSMakeRect(0, 0, mainFrame.width * CanvasGroup.FlagSize, mainFrame.height)
		flagLayer.path = NSBezierPath.withRoundedCorners(rect: flagRect, byRoundingCorners: [.minXMinY, .minXMaxY], withRadius: bgGradient.cornerRadius, includingEdges: [.all]).cgPath
		flagLayer.fillColor = flagColor.cgColor
		layer?.addSublayer(flagLayer)
		
		// type icon layer
		let iconLayer = CALayer()
		let typeIconSize = flagRect.width * CanvasGroup.IconSize // square as a percentage of the flag
		iconLayer.frame = NSMakeRect(0, 0, typeIconSize, typeIconSize)
		iconLayer.frame.setCenter(flagRect.center)
		iconLayer.contents = NSImage(named: NSImage.cautionName)
		iconLayer.contentsRect = NSMakeRect(0, 0, 1, 1)
		iconLayer.contentsGravity = .resizeAspectFill
		layer?.addSublayer(iconLayer)
		
		// label layer
		_labelLayer.string = "Alan please change this."
		_labelLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
		_labelLayer.font = NSFont.systemFont(ofSize: 1.0, weight: .light)
		_labelLayer.fontSize = 8.0
		_labelLayer.foregroundColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.75).cgColor
		_labelLayer.frame.size = _labelLayer.preferredFrameSize()
		_labelLayer.frame.origin = NSMakePoint(flagRect.maxX + CanvasGroup.LabelOffset, flagRect.midY - _labelLayer.frame.height * 0.5)
		_labelLayer.frame.size.width = mainFrame.width - _labelLayer.frame.minX
		_labelLayer.truncationMode = .middle
		layer?.addSublayer(_labelLayer)
		
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
