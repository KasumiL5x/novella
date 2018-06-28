//
//  LinkableView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class LinkableView: NSView {
	// MARK: - Constants -
	static let OUTPUTS_OFFSET_X: CGFloat = 6.0
	static let HIT_IGNORE_TAG: Int = 10
	static let HIT_NIL_TAG: Int = 11
	
	// MARK: - Variables -
	private var _nvLinkable: NVObject
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
	private var _contextItemAddLink: NSMenuItem
	private var _contextItemAddBranch: NSMenuItem
	private var _contextItemEntry: NSMenuItem
	private var _contextItemTrash: NSMenuItem
	
	// MARK: - Properties -
	var Linkable: NVObject {
		get{ return _nvLinkable }
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
	init(frameRect: NSRect, nvLinkable: NVObject, graphView: GraphView) {
		self._nvLinkable = nvLinkable
		self._graphView = graphView
		self._isPrimed = false
		self._isSelected = false
		//
		self._nameLabel = NSTextField(labelWithString: "")
		self._nameLabel.tag = LinkableView.HIT_IGNORE_TAG
		self._nameLabel.textColor = NSColor.fromHex("#3c3c3c")
		self._nameLabel.font = NSFont.systemFont(ofSize: 16.0, weight: .bold)
		self._nameLabel.placeholderString = "Unnamed"
		//
		self._contentLabel = NSTextField(wrappingLabelWithString: "")
		self._contentLabel.tag = LinkableView.HIT_IGNORE_TAG
		self._contentLabel.textColor = NSColor.fromHex("#3c3c3c")
		self._contentLabel.font = NSFont.systemFont(ofSize: 10.0, weight: .light)
		self._contentLabel.placeholderString = "Your node's content will appear here."
		//
		self._entryLabel = NSTextField(labelWithString: "Entry")
		self._entryLabel.tag = LinkableView.HIT_IGNORE_TAG
		self._entryLabel.textColor = NSColor.fromHex("#f2f2f2")
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
		self._contextItemAddLink = NSMenuItem(title: "Add Link", action: #selector(LinkableView.onContextAddLink), keyEquivalent: "")
		self._contextItemAddBranch = NSMenuItem(title: "Add Branch", action: #selector(LinkableView.onContextAddBranch), keyEquivalent: "")
		self._contextItemEntry = NSMenuItem(title: "Set as Entry", action: #selector(LinkableView.onContextSetEntry), keyEquivalent: "")
		self._contextItemTrash = NSMenuItem(title: "Trash", action: #selector(LinkableView.onContextTrash), keyEquivalent: "")
		super.init(frame: frameRect)
		
		// set up context menu
		_contextMenu.autoenablesItems = false
		_contextMenu.addItem(_contextItemAddLink)
		_contextMenu.addItem(_contextItemAddBranch)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_contextItemEntry)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_contextItemTrash)
		
		// add shadow
		wantsLayer = true
		layer?.masksToBounds = false
		self.shadow = NSShadow()
		self.layer?.shadowOpacity = 0.6
		self.layer?.shadowColor = NSColor.fromHex("#AEB8C7").cgColor
		self.layer?.shadowOffset = NSMakeSize(0.5, -1)
		self.layer?.shadowRadius = 0.3
		
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
		_clickGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onClick))
		_clickGesture!.buttonMask = 0x1 // "primary click"
		_clickGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_clickGesture!)
		// double click recognizer
		_doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onDoubleClick))
		_doubleClickGesture!.buttonMask = 0x1 // "primary click"
		_doubleClickGesture?.numberOfClicksRequired = 2
		self.addGestureRecognizer(_doubleClickGesture!)
		// context click recognizer
		_ctxGesture = NSClickGestureRecognizer(target: self, action: #selector(LinkableView.onContextClick))
		_ctxGesture!.buttonMask = 0x2 // "secondary click"
		_ctxGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(_ctxGesture!)
		// pan regoznizer
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(LinkableView.onPan))
		_panGesture!.buttonMask = 0x1 // "primary click"
		self.addGestureRecognizer(_panGesture!)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("LinkableView::init(coder) not implemented.")
	}
	
	// MARK: - Functions -
	
	// MARK: Hit Test
	override func hitTest(_ point: NSPoint) -> NSView? {
		// point is in the superview's coordinate system
		// manually check each subview's bounds (if i want to do something similar i'd need to override their hittest and call it here)
		for sub in subviews {
			if NSPointInRect(superview!.convert(point, to: sub), sub.bounds) {
				// return the node itself if a subview has the ignore tag (this is used for things like overlaying labels)
				if sub.tag == LinkableView.HIT_IGNORE_TAG {
					return self
				}
				if sub.tag == LinkableView.HIT_NIL_TAG {
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
		_graphView.onClickLinkable(node: self, gesture: gesture)
	}
	@objc private func onDoubleClick(gesture: NSGestureRecognizer) {
		if _trashMode { return }
		_graphView.onDoubleClickLinkable(node: self, gesture: gesture)
	}
	@objc private func onContextClick(gesture: NSGestureRecognizer) {
		NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
	}
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		_graphView.onPanLinkable(node: self, gesture: gesture)
	}
	
	// MARK: Context Menu Callbacks
	@objc private func onContextAddLink() {
		let link = _graphView.Manager.makeLink(origin: self.Linkable)
		do { try _graphView.NovellaGraph.add(link: link) } catch {
			fatalError("Tried to add a new link but couldn't add it to this graph.")
		}
	}
	@objc private func onContextAddBranch() {
		let link = _graphView.Manager.makeBranch(origin: self.Linkable)
		do{ try _graphView.NovellaGraph.add(link: link) } catch {
			fatalError("Tried to add a new branch but couldn't add it to this graph.")
		}
	}
	@objc private func onContextSetEntry() {
		try! _graphView.NovellaGraph.setEntry(self.Linkable)
	}
	@objc private func onContextTrash() {
		Linkable.InTrash ? Linkable.untrash() : Linkable.trash()
	}
	
	// MARK: Object Functions
	private func onTrashed() {
		_contextItemAddLink.isEnabled = !_trashMode
		_contextItemAddBranch.isEnabled = !_trashMode
		_contextItemEntry.isEnabled = !_trashMode
		_contextItemTrash.title = _trashMode ? "Untrash" : "Trash"
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
		self._entryLabel.isHidden = _graphView.NovellaGraph.Entry != self.Linkable
	}
	
	func redraw() {
		setNeedsDisplay(bounds)
	}
	
	// MARK: Virtual Functions
	func widgetRect() -> NSRect {
		// 40 = compact (w/o content label)
		// 100 = small
		// 150 = medium
		// 200 = large
		return NSMakeRect(0.0, 0.0, 200.0, 100.0)
	}
	func onMove() {
		print("LinkableView::onMove() should be overridden.")
	}
	func flagColor() -> NSColor {
		print("LinkableView::flagColor() should be overridden.")
		return NSColor.black
	}
	func onNameChanged() {
		print("LinkableView::onNameChanged() should be overridden.")
	}
	func onContentChanged() {
		print("LinkableView::onContentChanged() should be overridden.")
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
			curr.frame.origin.x = wRect.width + LinkableView.OUTPUTS_OFFSET_X
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
			let bgRadius: CGFloat = 4.0 // TODO: Make this a percentage of the drawingRect's width?
			var path = NSBezierPath(roundedRect: drawingRect, xRadius: bgRadius, yRadius: bgRadius)
			path.addClip()
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let bgStartColor = NSColor.fromHex("#FAFAFA")
			let bgEndColor = NSColor.fromHex("#FFFFFF")
			let bgColors = [
				Trashed ? bgStartColor.withSaturation(Settings.graph.trashedSaturation).cgColor : bgStartColor.cgColor,
				Trashed ? bgEndColor.withSaturation(Settings.graph.trashedSaturation).cgColor : bgEndColor.cgColor
			]
			let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 0.3])!
			let bgStart = CGPoint(x: 0, y: drawingRect.height)
			let bgEnd = CGPoint.zero
			context.drawLinearGradient(bgGradient, start: bgStart, end: bgEnd, options: CGGradientDrawingOptions(rawValue: 0))
			
			// draw type triangle
			let triangleSize: CGFloat = drawingRect.width * 0.15 // as a percentage of width
			context.move(to: NSMakePoint(drawingRect.minX, drawingRect.maxY))
			context.addLine(to: NSMakePoint(drawingRect.minX, drawingRect.maxY - triangleSize))
			context.addLine(to: NSMakePoint(drawingRect.minX + triangleSize, drawingRect.maxY))
			Trashed ? flagColor().withSaturation(Settings.graph.trashedSaturation).setFill() : flagColor().setFill()
			context.fillPath()
			
			// draw primed indicator
			if IsPrimed {
				let primedWidth: CGFloat = 4.5
				let primedColor = NSColor.fromHex("#4B9CFD")
				
				let insetRect = drawingRect
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = primedWidth
				Trashed ? primedColor.withSaturation(Settings.graph.trashedSaturation).setStroke() : primedColor.setStroke()
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
				path = NSBezierPath(roundedRect: insetRect, xRadius: bgRadius, yRadius: bgRadius)
				path.addClip() // clip to avoid edge artifacting
				path.lineWidth = selectedWidth
				if Trashed {
					selectedColor.withSaturation(Settings.graph.trashedSaturation).withAlphaComponent(selectedAlpha).setFill()
					selectedColor.withSaturation(Settings.graph.trashedSaturation).withAlphaComponent(selectedOutlineAlpha).setStroke()
				} else {
					selectedColor.withAlphaComponent(selectedAlpha).setFill()
					selectedColor.withAlphaComponent(selectedOutlineAlpha).setStroke()
				}
				path.fill()
				path.stroke()
			}
			
			// draw the entry point somewhere on the widget rect
			if self.Linkable == _graphView.NovellaGraph.Entry {
				let entrySize = drawingRect.width * 0.075
				let entryRect = NSMakeRect(drawingRect.maxX - entrySize*1.5, drawingRect.maxY - entrySize*1.5, entrySize, entrySize)
				NSColor.green.setFill()
				NSBezierPath(ovalIn: entryRect).fill()
			}
			
			context.restoreGState()
		}
	}
}
