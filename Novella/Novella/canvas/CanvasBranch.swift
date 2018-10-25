//
//  CanvasBranch.swift
//  novella
//
//  Created by dgreen on 11/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasBranch: CanvasObject {
	static let ROUNDNESS: CGFloat = 4.0
	
	override var tag: Int {
		return CustomTag.branch.rawValue
	}
	
	// MARK: - Variables
	private let _branchLabel: NSTextField
	private let _contentPopover: BranchPopover
	private var _contextMenu = NSMenu()
	private let _bench: Bench<NSView>
	
	// MARK: - Properties
	private(set) var Branch: NVBranch
	private(set) var TrueTransfer: Transfer
	private(set) var FalseTransfer: Transfer
	
	// MARK: - Initialization
	init(canvas: Canvas, nvBranch: NVBranch, bench: Bench<NSView>) {
		self._bench = bench
		self._branchLabel = NSTextField(labelWithString: "Branch")
		self.TrueTransfer = Transfer(size: 15.0, transfer: nvBranch.TrueTransfer, canvas: canvas)
		self.FalseTransfer = Transfer(size: 15.0, transfer: nvBranch.FalseTransfer, canvas: canvas)
		self.Branch = nvBranch
		self._contentPopover = BranchPopover()
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1))
		
		let rect = objectRect()
		frame.size = rect.size
		
		// branch label
		addSubview(_branchLabel)
		_branchLabel.translatesAutoresizingMaskIntoConstraints = false
		_branchLabel.tag = CustomTag.ignore.rawValue
		_branchLabel.textColor = NSColor.fromHex("#3C3C3C")
		_branchLabel.font = NSFont.systemFont(ofSize: 12.0, weight: .bold)
		_branchLabel.alignment = .left
		_branchLabel.sizeToFit()
		let branchLabelOffset = rect.width * 0.03
		_branchLabel.frame.origin = NSMakePoint(branchLabelOffset, rect.maxY - _branchLabel.frame.height - branchLabelOffset)
		
		// transfers
		TrueTransfer.OutlineColor = NSColor.fromHex("#87e5da")
		FalseTransfer.OutlineColor = NSColor.fromHex("#f34949")
		_bench.add(TrueTransfer)
		_bench.add(FalseTransfer)
		
		// make sure to size frame to fit transfers or they won't be interactible
		self.frame.size = subviewsSize()
		
		// context menu setup
		_contextMenu.addItem(withTitle: "Remove", action: #selector(CanvasBranch.onContextRemove), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasBranch::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	override func hitTest(_ point: NSPoint) -> NSView? {
		for sub in subviews {
			// subviews with ignore tag should return this view instead
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				if sub.tag == CustomTag.ignore.rawValue {
					return self
				}
				return sub.hitTest(superview!.convert(point, to: self))
			}
		}
		// check only the node rect region
		if NSPointInRect(superview!.convert(point, to: self), objectRect()) {
			return self
		}
		return nil
	}
	private func positionBench() {
		let rect = objectRect()
		_bench.frame.origin = NSMakePoint(rect.maxX + 10.0, rect.midY - _bench.bounds.midY)
	}
	private func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 80, 50)
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextRemove() {
		if Alerts.okCancel(msg: "Delete Branch?", info: "Are you sure you want to delete this branch? This action cannot be undone.", style: .critical) {
			TheCanvas.Doc.Story.deleteBranch(branch: self.Branch)
		}
	}
	
	// MARK: Virtuals
	override func onStateChange() {
		(_bench.Items as? [Transfer])?.forEach {
			$0.Focused = (self.CurrentState == .primed || self.CurrentState == .selected)
			$0.redraw()
		}
	}
	override func redraw() {
		super.redraw()
		setNeedsDisplay(bounds)
		TrueTransfer.setNeedsDisplay(TrueTransfer.bounds)
		FalseTransfer.setNeedsDisplay(FalseTransfer.bounds)
	}
	override func onMove() {
		super.onMove()
		TheCanvas.Doc.Positions[self.Branch.ID] = frame.origin + NSMakePoint(frame.width * 0.5, frame.height * 0.5)
		TrueTransfer.setNeedsDisplay(TrueTransfer.bounds)
		FalseTransfer.setNeedsDisplay(FalseTransfer.bounds)
	}
	override func onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_contentPopover.show(forView: self, at: .minY)
		_contentPopover.setup(branch: self.Branch)
	}
	
	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let drawingRect = objectRect()
			
			// draw background gradient
			let backgroundPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasBranch.ROUNDNESS, yRadius: CanvasBranch.ROUNDNESS)
			backgroundPath.addClip()
			let backgroundColors = [NSColor.fromHex("#FAFAFA").cgColor, NSColor.fromHex("#FFFFFF").cgColor]
			let backgroundGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: backgroundColors as CFArray, locations: [0.0, 0.3])!
			context.drawLinearGradient(backgroundGradient, start: NSMakePoint(0, drawingRect.height), end: NSPoint.zero, options: CGGradientDrawingOptions(rawValue: 0))
			
			// state (normal, primed, selected)
			switch CurrentState {
			case .normal:
				break
				
			case .primed:
				let primedWidth: CGFloat = 4.5
				let primedColor = NSColor.fromHex("#4B9CFD")
				let primedPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasBranch.ROUNDNESS, yRadius: CanvasBranch.ROUNDNESS)
				primedPath.addClip() // stops edge artifacting
				primedPath.lineWidth = primedWidth
				primedColor.setStroke()
				primedPath.lineJoinStyle = .miter
				primedPath.stroke()
				
			case .selected:
				let selWidth: CGFloat = 5.0
				let selColor = NSColor.fromHex("#4B9CFD")
				let selFillAlpha: CGFloat = 0.1
				let selOutlineAlpha: CGFloat = 0.6
				let selPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasBranch.ROUNDNESS, yRadius: CanvasBranch.ROUNDNESS)
				selPath.addClip() // stops edge artifacting
				selPath.lineWidth = selWidth
				selColor.withAlphaComponent(selFillAlpha).setFill()
				selColor.withAlphaComponent(selOutlineAlpha).setStroke()
				selPath.fill()
				selPath.stroke()
			}
			
			context.restoreGState()
		}
	}
}
