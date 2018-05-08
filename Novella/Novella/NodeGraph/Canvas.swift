//
//  Canvas.swift
//  Novella
//
//  Created by Daniel Green on 01/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class Canvas: NSView {
	// background grid
	var _grid: GridView
	
	// where nodes are stored
	var _linkableWidgets: [LinkableWidget]
	// where curves are stored
	var _curveWidgets: [CurveWidget]
	// selection rectangle
	var _selectionRect: SelectionView
	// selected nodes
	var _selectedNodes: [LinkableWidget]
	
	// dragging stuff
	var _prevMousePos: NSPoint
	
	// canvas-wide undo/redo
	let _undoRedo: UndoRedo
	
	// custom tracking area
	var _trackingArea: NSTrackingArea?
	
	override init(frame frameRect: NSRect) {
		_grid = GridView(frame: frameRect)
		
		_linkableWidgets = []
		
		_curveWidgets = []
		
		_selectionRect = SelectionView(frame: frameRect)
		_selectedNodes = []
		
		_prevMousePos = NSPoint.zero
		
		_undoRedo = UndoRedo()
		
		_trackingArea = nil
		
		super.init(frame: frameRect)
		
		// layers for subviews
		wantsLayer = true
		
		// initial state of canvas
		reset()
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Canvas::init(coder) not implemented.")
	}
	
	override func updateTrackingAreas() {
		if _trackingArea != nil {
			self.removeTrackingArea(_trackingArea!)
		}
		
		let options: NSTrackingArea.Options = [
			NSTrackingArea.Options.activeInKeyWindow,
			NSTrackingArea.Options.mouseMoved
		]
		_trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(_trackingArea!)
	}
	
	// MARK: Undo/Redo
	func undo() {
		_undoRedo.undo(levels: 1)
	}
	
	func redo() {
		_undoRedo.redo(levels: 1)
	}
	
	// MARK: Reset
	func reset() {
		// remove all subviews
		self.subviews.removeAll()
		
		// add background grid
		self.addSubview(_grid)
		// add marquee view (THIS MUST BE LAST)
		self.addSubview(_selectionRect)
		
		// remove all nodes
		_linkableWidgets = []
		
		// remove all curves
		_curveWidgets = []
		
		// clear undo/redo
		_undoRedo.clear()
	}
	
	// MARK: WIP
	func onMouseDownLinkableWidget(widget: LinkableWidget, event: NSEvent) {
		// update last position of cursor
		_prevMousePos = event.locationInWindow
		
		// if in selection, we may be wanting to move, so just ignore any selects.
		// this means that to deselect, you MUST select another unselected node or the canvas BG.
		if !_selectedNodes.contains(widget) {
			let appendSelection = event.modifierFlags.contains(.shift)
			select([widget], append: appendSelection)
		}
	}
	func onMouseDraggedLinkableWidget(widget: LinkableWidget, event: NSEvent) {
		// if no compound undo exists, make one now
		if !_undoRedo.inCompound() {
			_undoRedo.beginCompound(executeOnAdd: true)
		}
		
		let currMousePos = event.locationInWindow // may need tweaking
		let dx = (currMousePos.x - _prevMousePos.x)
		let dy = (currMousePos.y - _prevMousePos.y)
		_selectedNodes.forEach({
			let newOrigin = NSMakePoint($0.frame.origin.x + dx, $0.frame.origin.y + dy)
			moveLinkableWidget(widget: $0, from: $0.frame.origin, to: newOrigin)
		})
		
		// update last position of cursor
		_prevMousePos = currMousePos
	}
	func onMouseUpLinkableWidget(widget: LinkableWidget, event: NSEvent) {
		// end compound undo if one started
		if _undoRedo.inCompound() {
			_undoRedo.endCompound()
		}
	}
	
	// MARK: Canvas Widget Creation
	func makeDialogWidget(novellaDialog: Dialog) {
		let widget = DialogWidget(node: novellaDialog, canvas: self)
		_linkableWidgets.append(widget)
		self.addSubview(widget)
	}
	
	func makeLinkWidget(novellaLink: Link) {
		let widget = LinkWidget(link: novellaLink, canvas: self)
		_curveWidgets.append(widget)
		self.addSubview(widget)
	}
	
	func makeBranchWidget(novellaBranch: Branch) {
		let widget = BranchWidget(branch: novellaBranch, canvas: self)
		_curveWidgets.append(widget)
		self.addSubview(widget)
	}
	
	// MARK: Canvas-wide functions
	func moveLinkableWidget(widget: LinkableWidget, from: CGPoint, to: CGPoint) {
		_undoRedo.execute(cmd: MoveLinkableWidgetCmd(widget: widget, from: from, to: to))
	}
	
	// MARK: Convert Novella to Canvas
	func getLinkableWidgetFrom(linkable: Linkable?) -> LinkableWidget? {
		if linkable == nil {
			return nil
		}
		
		let widget = _linkableWidgets.first(where: {
			if let dlgWidget = $0 as? DialogWidget {
				return linkable?.UUID == dlgWidget._novellaDialog!.UUID
			}
			return false
		})
		
		return widget
	}
	
	// MARK: Curves
	func updateCurves() {
		// updates every curve - not very efficient
		for child in _curveWidgets {
			child.layer?.setNeedsDisplay()
		}
	}
	
	// MARK: Mouse Events
	override func mouseDown(with event: NSEvent) {
		// begin marquee mode
		_selectionRect.Origin = self.convert(event.locationInWindow, from: nil)
		_selectionRect.InMarquee = true
	}
	override func mouseDragged(with event: NSEvent) {
		// update marquee
		if _selectionRect.InMarquee {
			let curr = self.convert(event.locationInWindow, from: nil)
			_selectionRect.Marquee = NSMakeRect(fmin(_selectionRect.Origin.x, curr.x), fmin(_selectionRect.Origin.y, curr.y), fabs(curr.x - _selectionRect.Origin.x), fabs(curr.y - _selectionRect.Origin.y))
			return
		}
	}
	override func mouseUp(with event: NSEvent) {
		// handle marquee selection region
		if _selectionRect.InMarquee {
			let appendSelection = event.modifierFlags.contains(.shift)
			select(allNodesIn(rect: _selectionRect.Marquee), append: appendSelection)
			_selectionRect.Marquee = NSRect.zero
			_selectionRect.InMarquee = false
		}	else {
			// we just clicked, so remove selection
			select([], append: false)
		}
	}
	
	// MARK: Selection
	func select(_ nodes: [LinkableWidget], append: Bool) {
		_selectedNodes.forEach({$0.deselect()})
		_selectedNodes = append ? (_selectedNodes + nodes) : nodes
		_selectedNodes.forEach({$0.select()})
	}
	
	func allNodesIn(rect: NSRect) -> [LinkableWidget] {
		var selected: [LinkableWidget] = []
		for curr in _linkableWidgets {
			// note: bounds is relative to own coordinate system (0,0) and frame is relative to superview (_linkableWidgets).
			//       The frame and selection rect need to be in the same space (i.e. canvas size/space).
			if NSIntersectsRect(curr.frame, rect) {
				selected.append(curr)
			}
		}
		return selected
	}
}
