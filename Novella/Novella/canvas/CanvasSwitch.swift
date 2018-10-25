//
//  CanvasSwitch.swift
//  novella
//
//  Created by dgreen on 11/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class SwitchOption: NSView {
	private var _canvas: Canvas
	private var _bgLayer = CAShapeLayer()
	
	private(set) var TheOption: NVSwitchOption
	private(set) var TheTransfer: Transfer
	
	init(canvas: Canvas, transfer: Transfer, option: NVSwitchOption) {
		self._canvas = canvas
		self.TheTransfer = transfer
		self.TheOption = option
		super.init(frame: NSMakeRect(0, 0, 1, 1))
		
		// setup backing layer
		wantsLayer = true
		layer?.masksToBounds = false
		layer?.addSublayer(_bgLayer)
		
		// setup transfer
		addSubview(TheTransfer)
		
		// position transfer and expand frame to fit transfer including padding
		let padding: CGFloat = 2.0
		TheTransfer.frame.origin = NSMakePoint(padding, padding)
		frame.size = NSMakeSize(TheTransfer.frame.origin.x + TheTransfer.frame.width + padding, TheTransfer.frame.origin.y + TheTransfer.frame.height + padding)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("SwitchOption::init(coder) not implemented.")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let roundness: CGFloat = 6.0
			_bgLayer.fillColor = NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05).cgColor
			_bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: roundness, yRadius: roundness).cgPath
			
			context.restoreGState()
		}
	}
}

class CanvasSwitch: CanvasObject {
	static let ROUNDNESS: CGFloat = 4.0
	
	override var tag: Int {
		return CustomTag.swtch.rawValue
	}
	
	// MARK: - Variables
	private let _switchLabel: NSTextField
	private let _contentPopover = SwitchPopover()
	private let _optionPopover = SwitchOptionPopover()
	private let _contextMenu = NSMenu()
	private let _bench: Bench<NSView>
	
	// MARK: - Properties
	private(set) var Switch: NVSwitch
	
	// MARK: - Initialization
	init(canvas: Canvas, nvSwitch: NVSwitch, bench: Bench<NSView>) {
		self._bench = bench
		self._switchLabel = NSTextField(labelWithString: "Switch")
		self.Switch = nvSwitch
		super.init(canvas: canvas, frame: NSMakeRect(0, 0, 1, 1))
		
		let rect = objectRect()
		frame.size = rect.size
		
		// switch label
		addSubview(_switchLabel)
		_switchLabel.translatesAutoresizingMaskIntoConstraints = false
		_switchLabel.tag = CustomTag.ignore.rawValue
		_switchLabel.textColor = NSColor.fromHex("#3C3C3C")
		_switchLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .bold)
		_switchLabel.alignment = .left
		_switchLabel.sizeToFit()
		let switchLabelOffset = rect.width * 0.03
		self.addConstraints([
			NSLayoutConstraint(item: _switchLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: switchLabelOffset),
			NSLayoutConstraint(item: _switchLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: switchLabelOffset)
		])
		
		// add default transfer
		addOption(option: nvSwitch.DefaultOption)
		// add existing transfers
		for opt in nvSwitch.Options {
			addOption(option: opt)
		}
		
		// context menu setup
		_contextMenu.addItem(withTitle: "Add Option", action: #selector(CanvasSwitch.onContextAddOption), keyEquivalent: "")
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Remove", action: #selector(CanvasSwitch.onContextRemove), keyEquivalent: "")
	}
	required init?(coder decoder: NSCoder) {
		fatalError("CanvasSwitch::init(coder) not implemented.")
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
	private func objectRect() -> NSRect {
		return NSMakeRect(0, 0, 80, 50)
	}
	private func addOption(option: NVSwitchOption) {
		let canvasTransfer = Transfer(size: 15.0, transfer: option.transfer, canvas: TheCanvas)
		
		// bit of a hack, but make a separate menu for the default option as it has unique requirements.
		// because the menu is calling a function here away from it's "owner" we need to set the target to this object for each item added or it won't call.
		if option == Switch.DefaultOption {
			canvasTransfer.OutlineColor = NSColor.green
		} else {
			canvasTransfer.Menu.addItem(withTitle: "Edit Value", action: #selector(CanvasSwitch.onOptionContextEditValue), keyEquivalent: "").target = self
			canvasTransfer.Menu.addItem(NSMenuItem.separator())
			canvasTransfer.Menu.addItem(withTitle: "Remove", action: #selector(CanvasSwitch.onOptionContextRemove), keyEquivalent: "").target = self
		}
		
		let switchOption = SwitchOption(canvas: TheCanvas, transfer: canvasTransfer, option: option)
		
		// HACK: Assign all of the menu items' representedObject to this option so we can figure out which was clicked.
		canvasTransfer.Menu.items.forEach { (menuItem) in
			menuItem.representedObject = switchOption
		}
		
		_bench.add(switchOption)
	}
	private func addOption() {
		addOption(option: Switch.addOption())
	}
	
	// MARK: Switch Context Callbacks
	@objc private func onContextRemove() {
		if Alerts.okCancel(msg: "Delete Switch?", info: "Are you sure you want to delete this switch? This action cannot be undone.", style: .critical) {
			TheCanvas.Doc.Story.deleteSwitch(swtch: self.Switch)
		}
	}
	@objc private func onContextAddOption() {
		addOption()
	}
	
	// MARK: Option Context Callbacks
	@objc private func onOptionContextEditValue(sender: NSMenuItem) {
		guard let combo = sender.representedObject as? SwitchOption else {
			print("Tried to handle context click on a Switch Option but the menu's representedObject wasn't set.")
			return
		}
		
		_optionPopover.show(forView: combo, at: .maxX)
		_optionPopover.setup(option: combo.TheOption)
		
		print("This should edit the properties of transfer \(combo.TheTransfer) and option \(combo.TheOption)")
	}
	@objc private func onOptionContextRemove(sender: NSMenuItem) {
		guard let combo = sender.representedObject as? SwitchOption else {
			print("Tried to handle context click on a Switch Option but the menu's representedObject wasn't set.")
			return
		}
		
		if Alerts.okCancel(msg: "Delete Option?", info: "Are you sure you want to delete this option? This action cannot be undone.", style: .critical) {
			// remove from model
			Switch.removeOption(option: combo.TheOption)
			// remove from bench
			_bench.remove(combo)
		}
	}
	
	// MARK: Virtuals
	override func onStateChange() {
		(_bench.Items as? [SwitchOption])?.forEach{
			$0.TheTransfer.Focused = (self.CurrentState == .primed || self.CurrentState == .selected)
			$0.TheTransfer.redraw()
		}
	}
	override func onContextClick(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	override func onMove() {
		super.onMove()
		TheCanvas.Doc.Positions[self.Switch.ID] = frame.origin + NSMakePoint(frame.width * 0.5, frame.height * 0.5)
		(_bench.Items as? [SwitchOption])?.forEach{$0.TheTransfer.redraw()}
	}
	override func onDoubleClick(gesture: NSClickGestureRecognizer) {
		super.onDoubleClick(gesture: gesture)
		
		_contentPopover.show(forView: self, at: .minY)
		_contentPopover.setup(story: TheCanvas.Doc.Story, swtch: Switch)
	}
	override func redraw() {
		super.redraw()
		setNeedsDisplay(bounds)
	}
	
	// MARK: - Drawing
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let drawingRect = objectRect()
			
			// draw background gradient
			let backgroundPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasSwitch.ROUNDNESS, yRadius: CanvasSwitch.ROUNDNESS)
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
				let primedPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasSwitch.ROUNDNESS, yRadius: CanvasSwitch.ROUNDNESS)
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
				let selPath = NSBezierPath(roundedRect: drawingRect, xRadius: CanvasSwitch.ROUNDNESS, yRadius: CanvasSwitch.ROUNDNESS)
				selPath.addClip() // stops edge artifacting
				selPath.lineWidth = selWidth
				selColor.withAlphaComponent(selFillAlpha).setFill()
				selColor.withAlphaComponent(selOutlineAlpha).setStroke()
				selPath.fill()
				selPath.stroke()
			}
			
			
			// debug: draw light rectangle for the frame size
//			context.resetClip()
//			NSColor.red.withAlphaComponent(0.1).setFill()
//			NSBezierPath(rect: bounds).fill()
//			print("My bounds: \(bounds)")
//			print("benchbounds: \(TheBench.frame)")
			
			context.restoreGState()
		}
	}
}
