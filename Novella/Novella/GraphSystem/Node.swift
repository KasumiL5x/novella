//
//  Node.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class Node: NSView {
	// MARK: - Constants -
	static let OUTPUTS_OFFSET_X: CGFloat = 6.0
	static let HIT_IGNORE_TAG: Int = 10
	static let HIT_NIL_TAG: Int = 11
	static let NODE_ROUNDNESS: CGFloat = 4.0
	
	// MARK: - Variables -
	private var _nvObject: NVObject
	internal var _graphView: GraphView
	private var _isPrimed: Bool
	private var _isSelected: Bool
	private let _nameLabel: NSTextField
	private let _contentLabel: NSTextField
	private let _entryLabel: NSTextField
	//
	private var _clickGesture: NSClickGestureRecognizer?
	private var _doubleClickGesture: NSClickGestureRecognizer?
	private var _ctxGesture: NSClickGestureRecognizer?
	private var _panGesture: NSPanGestureRecognizer?
	//
	private var _outputs: [PinView]
	private var _outputsBoard: PinBoard
	//
	private var _trashMode: Bool
	//
	private var _contextMenu: NSMenu
	private var _contextItemEdit: NSMenuItem
	private var _contextItemAddLink: NSMenuItem
	private var _contextItemAddBranch: NSMenuItem
	private var _contextItemAddSwitch: NSMenuItem
	private var _contextItemEntry: NSMenuItem
	private var _contextItemTrash: NSMenuItem
	//
	var _editPopover: GenericPopover?
	
	// MARK: - Properties -
	var Object: NVObject {
		get{ return _nvObject }
	}
	var IsPrimed: Bool {
		get{ return _isPrimed }
	}
	var IsSelected: Bool {
		get{ return _isSelected }
	}
	public var Outputs: [PinView] {
		get{ return _outputs }
	}
	public var Trashed: Bool {
		get{ return _trashMode }
		set{
			_trashMode = newValue
			_outputs.forEach{$0.TrashMode = newValue}
			onTrashed()
			redraw()
		}
	}
	override var wantsDefaultClipping: Bool {
		return false
	}
	
	// MARK: - Initialization -
	init(frameRect: NSRect, nvObject: NVObject, graphView: GraphView) {
		self._nvObject = nvObject
		self._graphView = graphView
		self._isPrimed = false
		self._isSelected = false
		//
		self._nameLabel = NSTextField(labelWithString: "")
		self._nameLabel.tag = Node.HIT_IGNORE_TAG
		self._nameLabel.textColor = NSColor.fromHex("#3c3c3c")
		self._nameLabel.font = NSFont.systemFont(ofSize: 16.0, weight: .bold)
		self._nameLabel.placeholderString = "Unnamed"
		//
		self._contentLabel = NSTextField(wrappingLabelWithString: "")
		self._contentLabel.tag = Node.HIT_IGNORE_TAG
		self._contentLabel.textColor = NSColor.fromHex("#3c3c3c")
		self._contentLabel.font = NSFont.systemFont(ofSize: 10.0, weight: .light)
		self._contentLabel.placeholderString = "Your node's content will appear here."
		//
		self._entryLabel = NSTextField(labelWithString: "Entry")
		self._entryLabel.tag = Node.HIT_IGNORE_TAG
		self._entryLabel.textColor = NSColor.fromHex("#d2d2d2")
		self._entryLabel.font = NSFont.systemFont(ofSize: 10.0, weight: .bold)
		//
		self._clickGesture = nil
		self._doubleClickGesture = nil
		self._ctxGesture = nil
		self._panGesture = nil
		//
		self._outputs = []
		self._outputsBoard = PinBoard()
		//
		self._trashMode = false
		//
		self._contextMenu = NSMenu()
		self._contextItemEdit = NSMenuItem(title: "Edit", action: #selector(Node.onContextEdit), keyEquivalent: "")
		self._contextItemAddLink = NSMenuItem(title: "Add Link", action: #selector(Node.onContextAddLink), keyEquivalent: "")
		self._contextItemAddBranch = NSMenuItem(title: "Add Branch", action: #selector(Node.onContextAddBranch), keyEquivalent: "")
		self._contextItemAddSwitch = NSMenuItem(title: "Add Switch", action: #selector(Node.onContextAddSwitch), keyEquivalent: "")
		self._contextItemEntry = NSMenuItem(title: "Set as Entry", action: #selector(Node.onContextSetEntry), keyEquivalent: "")
		self._contextItemTrash = NSMenuItem(title: "Trash", action: #selector(Node.onContextTrash), keyEquivalent: "")
		//
		self._editPopover = nil
		super.init(frame: frameRect)
		
		// set up context menu
		_contextMenu.autoenablesItems = false
		_contextMenu.addItem(_contextItemEdit)
		_contextMenu.addItem(_contextItemAddLink)
		_contextMenu.addItem(_contextItemAddBranch)
		_contextMenu.addItem(_contextItemAddSwitch)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_contextItemEntry)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_contextItemTrash)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(withTitle: "Compact", action: #selector(Node.onContextSizeCompact), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Small", action: #selector(Node.onContextSizeSmall), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Medium", action: #selector(Node.onContextSizeMedium), keyEquivalent: "")
		_contextMenu.addItem(withTitle: "Large", action: #selector(Node.onContextSizeLarge), keyEquivalent: "")
		
		wantsLayer = true
		
		// add shadow
		layer?.masksToBounds = false
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.fromHex("#AEB8C7").cgColor
		self.layer?.shadowRadius = 0.5
		// shadows using offsets are a DRAMATIC performance hit, so avoid if possible.
		//self.layer?.shadowOffset = NSMakeSize(0.5, -1)
		// instead, make a shadow path that's precomputed
		var shadowRect = widgetRect()
		shadowRect.origin = NSMakePoint(0.7, -1.2)
		self.layer?.shadowPath = NSBezierPath(roundedRect: shadowRect, xRadius: Node.NODE_ROUNDNESS, yRadius: Node.NODE_ROUNDNESS).cgPath
		// OR rasterize the view, but this doesn't support retina and will be blurry
		//self.layer?.shouldRasterize = true
		//self.layer?.rasterizationScale = NSScreen.main!.backingScaleFactor
		
		self.addSubview(_outputsBoard)
		
		// name label
		setLabelString(str: "")
		self.addSubview(self._nameLabel)
		// content label
		setContentString(str: "")
		self.addSubview(self._contentLabel)
		
		// entry label
		self.addSubview(self._entryLabel)
		self._entryLabel.sizeToFit()
		self._entryLabel.frame.origin = NSMakePoint(3.0, 1.0)
		updateEntryLabel()
		
		// primary click recognizer
		_clickGesture = NSClickGestureRecognizer(target: self, action: #selector(Node.onClick))
		_clickGesture!.buttonMask = 0x1 // "primary click"
		_clickGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_clickGesture!)
		// double click recognizer
		_doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(Node.onDoubleClick))
		_doubleClickGesture!.buttonMask = 0x1 // "primary click"
		_doubleClickGesture?.numberOfClicksRequired = 2
		self.addGestureRecognizer(_doubleClickGesture!)
		// context click recognizer
		_ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(Node.onContextClick))
		_ctxGesture!.buttonMask = 0x2 // "secondary click"
		_ctxGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_ctxGesture!)
		// pan regoznizer
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(Node.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Node::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	
	// MARK: Hit Test
	override func hitTest(_ point: NSPoint) -> NSView? {
		// point is in the superview's coordinate system
		// manually check each subview's bounds (if i want to do something similar i'd need to override their hittest and call it here)
		for sub in subviews {
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				// return the node itself if a subview has the ignore tag (this is used for things like overlaying labels)
				if sub.tag == Node.HIT_IGNORE_TAG {
					return self
				}
				if sub.tag == Node.HIT_NIL_TAG {
					continue // just don't do anything with the view
				}
				return sub
			}
		}
		
		// check out local widget's bounds for a mouse click
		if NSPointInRect(superview!.convert(point, to: self), widgetRect()) {
			return self
		}
		
		// nuttin'
		return nil
	}
	
	// MARK: Gesture Callbacks
	@objc private func onClick(gesture: NSGestureRecognizer) {
		_graphView.onClickNode(node: self, gesture: gesture)
	}
	@objc private func onDoubleClick(gesture: NSGestureRecognizer) {
		if _trashMode { return }
		showEditPopover()
	}
	@objc private func onContextClick(gesture: NSGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		_graphView.onPanNode(node: self, gesture: gesture)
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextEdit() {
		showEditPopover()
	}
	@objc private func onContextAddLink() {
		let link = _graphView.Manager.makeLink(origin: self.Object)
		_graphView.NovellaGraph.add(link: link)
	}
	@objc private func onContextAddBranch() {
		let link = _graphView.Manager.makeBranch(origin: self.Object)
		_graphView.NovellaGraph.add(link: link)
	}
	@objc private func onContextAddSwitch() {
		let swtch = _graphView.Manager.makeSwitch(origin: self.Object)
		_graphView.NovellaGraph.add(link: swtch)
	}
	@objc private func onContextSetEntry() {
		let currentEntry = _graphView.getNodeFrom(object: _graphView.NovellaGraph.Entry, includeParentGraphs: false)
		_graphView.NovellaGraph.setEntry(self.Object)
		currentEntry?.redraw()
		self.redraw()
	}
	@objc private func onContextTrash() {
		Object.InTrash ? Object.untrash() : Object.trash()
	}
	
	@objc private func onContextSizeCompact() {
		if let asNode = Object as? NVNode {
			asNode.Size = .compact
		}
	}
	@objc private func onContextSizeSmall() {
		if let asNode = Object as? NVNode {
			asNode.Size = .small
		}
	}
	@objc private func onContextSizeMedium() {
		if let asNode = Object as? NVNode {
			asNode.Size = .medium
		}
	}
	@objc private func onContextSizeLarge() {
		if let asNode = Object as? NVNode {
			asNode.Size = .large
		}
	}
	
	// MARK: Popover Functions
	func _createPopover() {
		print("Node::_createPopover() should be overridden.")
	}
	func showEditPopover() {
		if let popover = _editPopover {
			popover.show(forView: self, at: .minY)
		} else {
			_createPopover()
		}
	}
	
	// MARK: Object Functions
	private func onTrashed() {
		_contextItemEdit.isEnabled = !_trashMode
		_contextItemAddLink.isEnabled = !_trashMode
		_contextItemAddBranch.isEnabled = !_trashMode
		_contextItemAddSwitch.isEnabled = !_trashMode
		_contextItemEntry.isEnabled = !_trashMode
		_contextItemTrash.title = _trashMode ? "Untrash" : "Trash"
	}
	
	func respondToSizeChange() {
		// reload and therefore reposition visual elements
		onNameChanged()
		onContentChanged()
		// actually redraw this view
		redraw()
		
		// layout the pins since the size changed
		layoutPins()
		// resize to fit subviews which contains the pins and also fits the new widget size
		sizeToFitSubviews()
		
		// update curves as the inputs to these need repositioning based on the new widget size
		_graphView.updateCurves()
		
		// remake shadow
		var shadowRect = widgetRect()
		shadowRect.origin = NSMakePoint(0.7, -1.2)
		self.layer?.shadowPath = NSBezierPath(roundedRect: shadowRect, xRadius: Node.NODE_ROUNDNESS, yRadius: Node.NODE_ROUNDNESS).cgPath
		
	}
	
	func setLabelString(str: String) {
		_nameLabel.stringValue = str
		self._nameLabel.sizeToFit()
		let x = widgetRect().width * 0.15
		self._nameLabel.frame.origin = NSMakePoint(x, widgetRect().maxY - x)
		self._nameLabel.frame.size.width = widgetRect().width - self._nameLabel.frame.minX
		self._nameLabel.lineBreakMode = .byTruncatingTail
	}
	
	func setContentString(str: String) {
		_contentLabel.stringValue = str
		_contentLabel.sizeToFit()
		let minX: CGFloat = 10.0
		let maxX: CGFloat = widgetRect().maxX - 10.0
		let minY: CGFloat = 10.0
		let maxY: CGFloat = widgetRect().maxY - 50.0
		_contentLabel.frame = NSMakeRect(minX, minY, maxX - minX, maxY - minY)
		_contentLabel.usesSingleLineMode = false
		
		_contentLabel.lineBreakMode = .byWordWrapping
	}
	
	func updateEntryLabel() {
		self._entryLabel.isHidden = _graphView.NovellaGraph.Entry != self.Object
	}
	
	func redraw() {
		// hide content label if compact
		if Object is NVNode {
			self._contentLabel.isHidden = (Object as! NVNode).Size == .compact
		} else {
			self._contentLabel.isHidden = true // graphs
		}
		setNeedsDisplay(bounds)
	}
	
	// MARK: Virtual Functions
	func widgetRect() -> NSRect {
		// 40 = compact (w/o content label)
		// 100 = small
		// 150 = medium
		// 200 = large
		
		let width: CGFloat = 200.0
		let compactSize = NSMakeRect(0.0, 0.0, width, 40.0)
		let smallSize = NSMakeRect(0.0, 0.0, width, 100.0)
		let mediumSize = NSMakeRect(0.0, 0.0, width, 150.0)
		let largeSize = NSMakeRect(0.0, 0.0, width, 200.0)
		
		if Object is NVNode {
			switch (Object as! NVNode).Size {
			case .compact:
				return compactSize
			case .small:
				return smallSize
			case .medium:
				return mediumSize
			case .large:
				return largeSize
			default:
				print("Node::widgetRect() encountered an NVNode with an unexpected size.")
				return smallSize
			}
		} else {
			return compactSize
		}
	}
	func onMove() {
		print("Node::onMove() should be overridden.")
	}
	func flagColor() -> NSColor {
		print("Node::flagColor() should be overridden.")
		return NSColor.black
	}
	func onNameChanged() {
		print("Node::onNameChanged() should be overridden.")
	}
	func onContentChanged() {
		print("Node::onContentChanged() should be overridden.")
	}
	
	// MARK: Priming/Selection
	func select() {
		_isSelected = true
		_isPrimed = false
		setNeedsDisplay(bounds)
		_outputs.forEach{$0.redraw()}
	}
	func deselect() {
		_isSelected = false
		_isPrimed = false
		setNeedsDisplay(bounds)
		_outputs.forEach{$0.redraw()}
	}
	func prime() {
		_isSelected = false
		_isPrimed = true
		setNeedsDisplay(bounds)
		_outputs.forEach{$0.redraw()}
	}
	func unprime() {
		_isSelected = false
		_isPrimed = false
		setNeedsDisplay(bounds)
		_outputs.forEach{$0.redraw()}
	}
	
	// MARK: Movement
	func move(to: CGPoint) {
		frame.origin = to
		onMove()
		_graphView.updateCurves()
	}
	
	// MARK: Outputs
	func addOutput(pin: PinView) {
		_outputs.append(pin)
		self.addSubview(pin)
		layoutPins()
		sizeToFitSubviews() // subviews cannot be interacted with if they are out of the bounds of the superview, so resize
		
		setNeedsDisplay(bounds)
	}
	func removeOutput(pin: PinView) {
		if let idx = _outputs.index(of: pin) {
			_outputs.remove(at: idx)
			pin.removeFromSuperview()
			layoutPins()
		}
	}
	private func layoutPins() {
		if _outputs.isEmpty {
			_outputsBoard.frame = NSRect.zero // remove outputs board (size to zero)
			_outputsBoard.setNeedsDisplay(_outputsBoard.bounds)
			return
		}
		
		// set first pin at origin
		_outputs[0].frame.origin = CGPoint.zero
		
		// align all other views accordingly
		let spacing: CGFloat = 5.0
		var lastY = _outputs[0].bounds.height
		if _outputs.count > 1 {
			for i in 1..<_outputs.count {
				_outputs[i].frame.origin = NSMakePoint(0.0, lastY + spacing)
				lastY += _outputs[i].bounds.height + spacing
			}
		}
		
		// calculate center Y (since at origin can just half height of stack, i.e. last element)
		let centerY = _outputs.last!.frame.maxY * 0.5
		
		// calculate difference between the stack's center and the widget's rect's center
		let wRect = widgetRect()
		let yDiff = (wRect.height*0.5) - centerY
		
		// move all views up by the diff and set fixed X
		for curr in _outputs {
			curr.frame.origin.y += yDiff
			curr.frame.origin.x = wRect.width + Node.OUTPUTS_OFFSET_X
		}
		
		// set bounds frame and adjust it for the offset
		_outputsBoard.frame = boundsOf(views: _outputs)
		let border = NSMakeSize(6.0, 8.0)
		_outputsBoard.frame.size.width += border.width
		_outputsBoard.frame.size.height += border.height
		_outputsBoard.frame.origin.x -= border.width * 0.5
		_outputsBoard.frame.origin.y -= border.height * 0.5
		_outputsBoard.setNeedsDisplay(_outputsBoard.frame)
	}
	private func boundsOf(views: [NSView]) -> NSRect {
		var minX = CGFloat.infinity
		var maxX = -CGFloat.infinity
		var minY = CGFloat.infinity
		var maxY = -CGFloat.infinity
		for curr in views {
			minX = curr.frame.minX < minX ? curr.frame.minX : minX
			maxX = curr.frame.maxX > maxX ? curr.frame.maxX : maxX
			minY = curr.frame.minY < minY ? curr.frame.minY : minY
			maxY = curr.frame.maxY > maxY ? curr.frame.maxY : maxY
		}
		return NSMakeRect(minX, minY, maxX - minX, maxY - minY)
	}
	private func sizeToFitSubviews() {
		// initially set frame size to widget ret
		frame.size = widgetRect().size
		
		var w: CGFloat = frame.width
		var h: CGFloat = frame.height
		for sub in subviews {
			let sw = sub.frame.origin.x + sub.frame.width
			let sh = sub.frame.origin.y + sub.frame.height
			w = max(w, sw)
			h = max(h, sh)
		}
		self.frame.size = NSMakeSize(w, h)
	}
	
	// MARK: - Drawing -
	override func draw(_ dirtyRect: NSRect) {
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			// create drawing rect for this object
			let drawingRect = widgetRect()
			
			// draw background gradient
			var path = NSBezierPath(roundedRect: drawingRect, xRadius: Node.NODE_ROUNDNESS, yRadius: Node.NODE_ROUNDNESS)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgStartColor = NSColor.fromHex("#FAFAFA")
			let bgEndColor = NSColor.fromHex("#FFFFFF")
			let bgColors = [bgStartColor.cgColor, bgEndColor.cgColor]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: drawingRect.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			// draw type triangle
			let triangleSize: CGFloat = drawingRect.width * 0.15 // as a percentage of width
			context.move(to: NSMakePoint(drawingRect.minX, drawingRect.maxY))
			context.addLine(to: NSMakePoint(drawingRect.minX, drawingRect.maxY - triangleSize))
			context.addLine(to: NSMakePoint(drawingRect.minX + triangleSize, drawingRect.maxY))
			Trashed ? Settings.graph.trashedColorLight.setFill() : flagColor().setFill()
			context.fillPath()
			
			// draw primed indicator
			if IsPrimed {
				let primedWidth: CGFloat = 4.5
				let primedColor = NSColor.fromHex("#4B9CFD")
				
				let insetRect = drawingRect
				path = NSBezierPath(roundedRect: insetRect, xRadius: Node.NODE_ROUNDNESS, yRadius: Node.NODE_ROUNDNESS)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = primedWidth
				Trashed ? Settings.graph.trashedColorDark.setStroke() : primedColor.setStroke()
				path.lineJoinStyle = .miterLineJoinStyle
				path.stroke()
			}
			
			// draw selection indicator
			if IsSelected {
				let selectedWidth: CGFloat = 5.0
				let selectedColor = NSColor.fromHex("#4B9CFD")
				let selectedAlpha: CGFloat = 0.1
				let selectedOutlineAlpha: CGFloat = 0.6
				
				let insetRect = drawingRect
				path = NSBezierPath(roundedRect: insetRect, xRadius: Node.NODE_ROUNDNESS, yRadius: Node.NODE_ROUNDNESS)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = selectedWidth
				if Trashed {
					Settings.graph.trashedColorDark.withAlphaComponent(selectedAlpha).setFill()
					Settings.graph.trashedColorDark.withAlphaComponent(selectedOutlineAlpha).setStroke()
				} else {
					selectedColor.withAlphaComponent(selectedAlpha).setFill()
					selectedColor.withAlphaComponent(selectedOutlineAlpha).setStroke()
				}
				path.fill()
				path.stroke()
			}
			
			// draw the entry point somewhere on the widget rect
			if self.Object == _graphView.NovellaGraph.Entry {
				let entrySize = drawingRect.width * 0.03
				let arrowCenter = NSMakePoint(drawingRect.maxX - entrySize*2.0, drawingRect.maxY - entrySize*2.0)
				let arrowPath = NSBezierPath()
				arrowPath.move(to: NSMakePoint(arrowCenter.x - entrySize, arrowCenter.y + entrySize))
				arrowPath.line(to: NSMakePoint(arrowCenter.x + entrySize, arrowCenter.y))
				arrowPath.line(to: NSMakePoint(arrowCenter.x - entrySize, arrowCenter.y - entrySize))
				NSColor.fromHex("#4ecca3").setFill()
				arrowPath.fill()
			}
			
			context.restoreGState()
		}
	}
}
