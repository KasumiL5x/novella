//
//  Node.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

/// Base class for canvas nodes (dialog, delivery, etc.).
class CanvasNode: CanvasObject {
	static let ROUNDNESS: CGFloat = 4.0
	static let TAG_HIT_IGNORE: Int = 42
	
	// MARK: - Variables
	private let _nameLabel: NSTextField
	private let _contentLabel: NSTextField
	private var _contextMenu = NSMenu()
	private var _bench: Bench<NSView>
	
	// MARK: - Properties
	private(set) var Node: NVNode
	
	// MARK: - Initialization
	init(canvas: Canvas, nvNode: NVNode, bench: Bench<NSView>) {
		self._bench = bench
		
		// name label
		_nameLabel = NSTextField(labelWithString: "")
		_nameLabel.tag = CanvasNode.TAG_HIT_IGNORE
		_nameLabel.textColor = NSColor.fromHex("#3C3C3C")
		_nameLabel.font = NSFont.systemFont(ofSize: 16.0, weight: .bold)
		_nameLabel.placeholderString = "Unnamed"
		
		// content label
		_contentLabel = NSTextField(wrappingLabelWithString: "")
		_contentLabel.tag = CanvasNode.TAG_HIT_IGNORE
		_contentLabel.textColor = NSColor.fromHex("#3C3C3C")
		_contentLabel.font = NSFont.systemFont(ofSize: 10.0, weight: .light)
		_contentLabel.placeholderString = "A preview of the node's content will appear here."
		
		self.Node = nvNode
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1)) // anything nonzero for frame as we resize in a moment
		
		// for reuse in setup
		let rect = nodeRect()
		
		// name label
		addSubview(_nameLabel)
		_nameLabel.alignment = .left
		let nameLabelOffset = rect.width * 0.15
		_nameLabel.frame.origin = NSMakePoint(nameLabelOffset, rect.maxY - nameLabelOffset)
		_nameLabel.frame.size.width = rect.width - _nameLabel.frame.minX
		_nameLabel.lineBreakMode = .byTruncatingTail
		
		// content label
		addSubview(_contentLabel)
		let contentMinX: CGFloat = 10.0
		let contentMaxX: CGFloat = rect.maxX - 10.0
		let contentMinY: CGFloat = 10.0
		let contentMaxY: CGFloat = rect.maxY - 30.0
		_contentLabel.frame = NSMakeRect(contentMinX, contentMinY, contentMaxX - contentMinX, contentMaxY - contentMinY)
		_contentLabel.usesSingleLineMode = false
		_contentLabel.lineBreakMode = .byWordWrapping
		_contentLabel.isEnabled = false // may need to fix this
		
		frame.size = nodeRect().size
		
		// context menu setup
		_contextMenu.addItem(withTitle: "Add Link", action: #selector(CanvasNode.onContextAddLink), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Set as Entry", action: #selector(CanvasNode.onContextSetAsEntry), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Remove", action: #selector(CanvasNode.onContextRemove), keyEquivalent: "")
		
		// set inital data from model
		reloadFromModel()
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasNode::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	// MARK: Context Menu Callbacks
	@objc private func onContextAddLink() {
		_bench.add(TheCanvas.makeLink(origin: self.Node, nvLink: nil))
	}
	@objc private func onContextSetAsEntry() {
		let oldEntry = TheCanvas.Graph.Entry
		TheCanvas.Graph.Entry = self.Node
		if let oldEntry = oldEntry {
			TheCanvas.canvasObjectFor(nvLinkable: oldEntry)?.redraw()
		}
		redraw()
	}
	@objc private func onContextRemove() {
		if Alerts.okCancel(msg: "Delete Node?", info: "Are you sure you want to delete this node? This action cannot be undone.", style: .critical) {
			TheCanvas.Doc.Story.deleteNode(node: self.Node)
		}
	}
	// MARK: Virtuals
	override func onStateChange() {
		(_bench.Items as? [Link])?.forEach{
			$0.TheTransfer?.Focused = (self.CurrentState == .primed || self.CurrentState == .selected)
			$0.TheTransfer?.redraw()
		}
	}
	override func onClick(gesture: NSClickGestureRecognizer) {
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
	}
	override func onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	override func onPan(gesture: NSPanGestureRecognizer) {
	}
	override func redraw() {
		super.redraw()
		setNeedsDisplay(bounds)
	}
	override func onMove() {
		super.onMove()
		TheCanvas.Doc.Positions[self.Node.ID] = frame.origin + NSMakePoint(frame.width * 0.5, frame.height * 0.5)
		(_bench.Items as? [Link])?.forEach{$0.redraw()}
	}
	
	// MARK: Node-Specific Functionality
	override func hitTest(_ point: NSPoint) -> NSView? {
		for sub in subviews {
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				// subviews with ignore tag should return this view instead
				if sub.tag == CanvasNode.TAG_HIT_IGNORE {
					return self
				}
				return sub.hitTest(superview!.convert(point, to: self)) // delegate to sub using point in this view's coords
			}
		}
		
		// check only the node rect region
		if NSPointInRect(superview!.convert(point, to: self), nodeRect()) {
			return self
		}
		
		return nil
	}
	
	/// Returns the rectangle used for this node's drawing/hit test (the actual frame size is larger due to subviews).
	func nodeRect() -> NSRect {
		let size = NSMakeRect(0, 0, 150.0, 80.0)
		return size
	}
	
	func setNameLabel(_ str: String) {
		_nameLabel.stringValue = str
		_nameLabel.toolTip = str
	}
	func setContentLabel(_ str: String) {
		_contentLabel.stringValue = str
		_contentLabel.toolTip = str
	}
	
	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// this node's rect for drawing and hittest regardless of frame size
			let drawingRect = nodeRect()
			
			// draw background gradient
			let backgroundPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasNode.ROUNDNESS, yRadius: CanvasNode.ROUNDNESS)
			backgroundPath.addClip()
			let backgroundColors = [NSColor.fromHex("#FAFAFA").cgColor, NSColor.fromHex("#FFFFFF").cgColor]
			let backgroundGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: backgroundColors as CFArray, locations: [0.0, 0.3])!
			context.drawLinearGradient(backgroundGradient, start: NSMakePoint(0, drawingRect.height), end: NSPoint.zero, options: CGGradientDrawingOptions(rawValue: 0))
			
			// type triangle
			let triangleSize = drawingRect.width * 0.15 // as a percentage of the node rect's width
			context.move(to: NSMakePoint(drawingRect.minX, drawingRect.maxY))
			context.addLine(to: NSMakePoint(drawingRect.minX, drawingRect.maxY - triangleSize))
			context.addLine(to: NSMakePoint(drawingRect.minX + triangleSize, drawingRect.maxY))
			color().setFill()
			context.fillPath()
			
			// entry point flag
			if self.Node == TheCanvas.Graph.Entry {
				let entrySize = drawingRect.width * 0.03
				let arrowCenter = NSMakePoint(drawingRect.maxX - entrySize*2.0, drawingRect.maxY - entrySize*2.0)
				let arrowPath = NSBezierPath()
				arrowPath.move(to: NSMakePoint(arrowCenter.x - entrySize, arrowCenter.y + entrySize))
				arrowPath.line(to: NSMakePoint(arrowCenter.x + entrySize, arrowCenter.y))
				arrowPath.line(to: NSMakePoint(arrowCenter.x - entrySize, arrowCenter.y - entrySize))
				NSColor.fromHex("#4ecca3").setFill()
				arrowPath.fill()
			}
			
			// state (normal, primed, selected)
			switch CurrentState {
			case .normal:
				break
				
			case .primed:
				let primedWidth: CGFloat = 4.5
				let primedColor = NSColor.fromHex("#4B9CFD")
				let primedPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasNode.ROUNDNESS, yRadius: CanvasNode.ROUNDNESS)
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
				let selPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasNode.ROUNDNESS, yRadius: CanvasNode.ROUNDNESS)
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
