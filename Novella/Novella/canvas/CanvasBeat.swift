//
//  CanvasBeat.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CanvasBeat: CanvasObject {
	static let Roundness: CGFloat = 0.2
	static let FlagWidth: CGFloat = 0.175
	
	let Beat: NVBeat
	private let _outlineLayer: CAShapeLayer
	private let _labelLayer: CATextLayer
	
	init(canvas: Canvas, beat: NVBeat) {
		self.Beat = beat
		self._outlineLayer = CAShapeLayer()
		self._labelLayer = CATextLayer()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 90, 75))
		
		ContextMenu.addItem(withTitle: "Submerge", action: #selector(CanvasBeat.onSubmerge), keyEquivalent: "")
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// main background layer
		let bgGradient = CAGradientLayer()
		bgGradient.frame = objectRect()
		bgGradient.cornerRadius = (max(bgGradient.frame.width, bgGradient.frame.height) * 0.5) * CanvasBeat.Roundness
		bgGradient.colors = [NSColor.fromHex("#F5F7FA").cgColor, NSColor.fromHex("#FFFFFF").cgColor]
		bgGradient.startPoint = NSPoint.zero
		bgGradient.endPoint = NSMakePoint(0.0, 1.0)
		bgGradient.locations = [0.0, 0.3]
		layer?.addSublayer(bgGradient)
		
		// mask for flag based on main backgound layer
		let flagMask = CAShapeLayer()
		flagMask.path = NSBezierPath(roundedRect: bgGradient.frame, xRadius: bgGradient.cornerRadius, yRadius: bgGradient.cornerRadius).cgPath
		// flag layer
		let flagLayer = CAShapeLayer()
		var flagRect = bgGradient.frame
		flagRect.size.width *= CanvasBeat.FlagWidth
		flagLayer.path = NSBezierPath(roundedRect: flagRect, xRadius: 0.0, yRadius: 0.0).cgPath
		flagLayer.strokeColor = nil
		flagLayer.fillColor = NSColor.fromHex("#FF5E3A").cgColor
		flagLayer.mask = flagMask
		layer?.addSublayer(flagLayer)
		
		// outline layer
		_outlineLayer.path = NSBezierPath(roundedRect: bgGradient.frame, xRadius: bgGradient.cornerRadius, yRadius: bgGradient.cornerRadius).cgPath
		_outlineLayer.fillColor = nil
		_outlineLayer.strokeColor = CGColor.clear
		layer?.addSublayer(_outlineLayer)
		
		// label
		_labelLayer.string = "Unnamed"
		_labelLayer.contentsScale = NSScreen.main!.backingScaleFactor
		_labelLayer.font = NSFont.systemFont(ofSize: 1.0, weight: .bold)
		_labelLayer.fontSize = 13.0
		_labelLayer.foregroundColor = NSColor.fromHex("#3C3C3C").withAlphaComponent(0.75).cgColor
		_labelLayer.frame.size = _labelLayer.preferredFrameSize()
		_labelLayer.frame.origin = NSMakePoint(flagRect.maxX + 3.0, flagRect.maxY - _labelLayer.frame.size.height)
		_labelLayer.frame.size.width = bgGradient.frame.width - _labelLayer.frame.origin.x
		_labelLayer.isWrapped = true
		_labelLayer.truncationMode = .middle
		layer?.addSublayer(_labelLayer)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}

	@objc private func onSubmerge() {
		_canvas.setupFor(beat: self.Beat)
	}
	
	// virtuals
	override func onClick(gesture: NSClickGestureRecognizer) {
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
	}
	override func onContextClick(gesture: NSClickGestureRecognizer) {
	}
	override func onPan(gesture: NSPanGestureRecognizer) {
	}
	override func onMove() {
		_canvas.Doc.Positions[Beat.UUID] = frame.origin
	}
	override func onStateChanged() {
		switch CurrentState {
		case .normal:
			_outlineLayer.lineWidth = 0.0
			_outlineLayer.strokeColor = CGColor.clear
		case .primed:
			_outlineLayer.lineWidth = 2.0
			_outlineLayer.strokeColor = NSColor.fromHex("#4B9CFD").cgColor
		case .selected:
			_outlineLayer.lineWidth = 4.0
			_outlineLayer.strokeColor = NSColor.fromHex("#4B9CFD").cgColor
		}
	}
	override func redraw() {
	}
}
