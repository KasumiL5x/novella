//
//  Canvas.swift
//  Novella
//
//  Created by Daniel Green on 01/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class Canvas: NSView {
	var _nvStory: NVStory?

	var _grid: GridView

	var _linkableWidgets: [LinkableWidget]
	var _linkPinViews: [LinkPinView]

	var _selectionRect: SelectionView
	var _selectedNodes: [LinkableWidget]
	var _trackingArea: NSTrackingArea?
	var _prevMousePos: NSPoint // used for dragging

	let _undoRedo: UndoRedo

	var _pinDropTarget: LinkableWidget? // target node when dragging pins
	var _pinDropDragged: LinkPinView? // current one being dragged
	var _pinDropMenuBranch: NSMenu
	
	// context menu for right clicking on linkable widgets
	var _linkableWidgetMenu: NSMenu
	var _rightClickedLinkable: LinkableWidget?
	
	// context menu for right click canvas
	var _canvasMenu: NSMenu

	init(frame frameRect: NSRect, story: NVStory) {
		self._nvStory = story

		self._grid = GridView(frame: frameRect)

		self._linkableWidgets = []
		self._linkPinViews = []

		self._selectionRect = SelectionView(frame: frameRect)
		self._selectedNodes = []

		self._trackingArea = nil
		self._prevMousePos = NSPoint.zero

		self._undoRedo = UndoRedo()

		self._pinDropTarget = nil
		self._pinDropDragged = nil
		self._pinDropMenuBranch = NSMenu(title: "Branch Menu")
		
		self._linkableWidgetMenu = NSMenu(title: "LinkableWidget Menu")
		self._rightClickedLinkable = nil
		
		self._canvasMenu = NSMenu(title: "Canvas Menu")

		super.init(frame: frameRect)

		// set up the pin drop branch menu
		_pinDropMenuBranch.addItem(withTitle: "True", action: #selector(Canvas.onPinDropBranchTrue), keyEquivalent: "")
		_pinDropMenuBranch.addItem(withTitle: "False", action: #selector(Canvas.onPinDropBranchFalse), keyEquivalent: "")
		
		// set up the linkable widget rmb menu
		_linkableWidgetMenu.addItem(withTitle: "Add Link", action: #selector(Canvas.onLinkableWidgetMenuAddLink), keyEquivalent: "")
		_linkableWidgetMenu.addItem(withTitle: "Add Branch", action: #selector(Canvas.onLinkableWidgetMenuAddBranch), keyEquivalent: "")
		
		// set up the canvas rmb menu
		_canvasMenu.addItem(withTitle: "Test", action: nil, keyEquivalent: "")
		
		reset(to: story)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Canvas::init(coder) not implemented.")
	}

	// configures the tracking area
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

	// MARK: Story
	func loadFrom(story: NVStory) {
		reset(to: story)

		// add all nodes
		for curr in story.AllNodes {
			if let asDialog = curr as? NVDialog {
				let _ = makeDialogWidget(novellaDialog: asDialog)
			} else {
				print("Encounterd node type that's not handled in Canvas yet (\(type(of:curr))).")
			}
		}

		// create all links
		for curr in story.AllLinks {
			if let node = getLinkableWidgetFrom(linkable: curr.Origin) {
				node.addOutput(pin: makeLinkPin(nvBaseLink: curr, forWidget: node))
			} else {
				fatalError("Recived a link without an origin!")
			}
		}

		print("Loaded story!")
	}

	// MARK: Undo/Redo
	func undo() {
		_undoRedo.undo(levels: 1)
	}

	func redo() {
		_undoRedo.redo(levels: 1)
	}

	// MARK: Reset
	func reset(to: NVStory) {
		// remove all subviews
		self.subviews.removeAll()

		// add background grid
		self.addSubview(_grid)
		// add marquee view (THIS MUST BE LAST)
		self.addSubview(_selectionRect)

		// remove all nodes
		_linkableWidgets = []
		// remove all link pins
		_linkPinViews = []
		
		// replace selection with nothing
		select([], append: false)
		
		// pin drop stuff
		self._pinDropTarget = nil
		self._pinDropDragged = nil

		// clear undo/redo
		_undoRedo.clear()
		
		// make a default empty story
		self._nvStory = to
	}

	// MARK: Convert Novella to Canvas
	func getLinkableWidgetFrom(linkable: NVLinkable?) -> LinkableWidget? {
		if linkable == nil {
			return nil
		}

		return _linkableWidgets.first(where: {
			if let dlgWidget = $0 as? DialogWidget {
				return linkable?.UUID == dlgWidget.Linkable!.UUID
			}
			return false
		})
	}

	// MARK: Curves
	func updateCurves() {
		// updates every curve - not very efficient
		for child in _linkPinViews {
			child.redraw()
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
			_selectionRect.Marquee.origin = NSMakePoint(fmin(_selectionRect.Origin.x, curr.x), fmin(_selectionRect.Origin.y, curr.y))
			_selectionRect.Marquee.size = NSMakeSize(fabs(curr.x - _selectionRect.Origin.x), fabs(curr.y - _selectionRect.Origin.y))
		}
	}

	override func mouseUp(with event: NSEvent) {
		// handle marquee selection region
		if _selectionRect.InMarquee {
			select(allNodesIn(rect: _selectionRect.Marquee), append: event.modifierFlags.contains(.shift))
			_selectionRect.Marquee = NSRect.zero
			_selectionRect.InMarquee = false
		}	else {
			// we just clicked, so remove selection
			select([], append: false)
		}
	}
	
	override func rightMouseDown(with event: NSEvent) {
		NSMenu.popUpContextMenu(_canvasMenu, with: event, for: self)
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

// MARK: LinkableWidget Stuff
extension Canvas {
	// MARK: Creation
	@discardableResult
	func makeDialogWidget(novellaDialog: NVDialog) -> DialogWidget {
		let widget = DialogWidget(node: novellaDialog, canvas: self)
		_linkableWidgets.append(widget)
		self.addSubview(widget, positioned: .below, relativeTo: _selectionRect) // make sure _selectionRect stays on top
		return widget
	}

	// MARK: Mouse Events
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

	func onRightMouseDownLinkableWidget(widget: LinkableWidget, event: NSEvent) {
		_rightClickedLinkable = widget
		NSMenu.popUpContextMenu(_linkableWidgetMenu, with: event, for: widget)
	}

	// MARK: Command Functions
	func moveLinkableWidget(widget: LinkableWidget, from: CGPoint, to: CGPoint) {
		_undoRedo.execute(cmd: MoveLinkableWidgetCmd(widget: widget, from: from, to: to))
	}

	// MARK: Context Menus
	@objc func onLinkableWidgetMenuAddLink(sender: NSMenuItem) {
		if _rightClickedLinkable == nil {
			fatalError("Attempted to add link to LinkableWidget but _rightClickedLinkable was nil.")
		}
		if _nvStory == nil {
			fatalError("Attempted to make some link but there was no story???")
		}
		
		let linkable = _rightClickedLinkable!.Linkable
		let link = _nvStory!.makeLink(origin: linkable!)
		_rightClickedLinkable!.addOutput(pin: makeLinkPin(nvBaseLink: link, forWidget: _rightClickedLinkable!))
	}
	@objc func onLinkableWidgetMenuAddBranch(sender: NSMenuItem) {
		if _rightClickedLinkable == nil {
			fatalError("Attempted to add link to LinkableWidget but _rightClickedLinkable was nil.")
		}
		if _nvStory == nil {
			fatalError("Attempted to make some link but there was no story???")
		}
		
		let link = _nvStory!.makeBranch(origin: _rightClickedLinkable!.Linkable!)
		_rightClickedLinkable!.addOutput(pin: makeLinkPin(nvBaseLink: link, forWidget: _rightClickedLinkable!))
	}
}

// MARK: Links Stuff
extension Canvas {
	// MARK: Creation
	func makeLinkPin(nvBaseLink: NVBaseLink, forWidget: LinkableWidget) -> LinkPinView {
		let lpv = LinkPinView(link: nvBaseLink, canvas: self, owner: forWidget)
		_linkPinViews.append(lpv)
		return lpv
	}

	func onDragPin(pin: LinkPinView, event: NSEvent) {
		_pinDropDragged = pin
		_pinDropTarget = nil

		for sub in _linkableWidgets {
			let pos = self.convert(event.locationInWindow, from: nil) // MUST be in canvas space, as the subviews hitTest relies on the superview (canvas) space
			let hitView = sub.hitTest(pos)

			// didn't hit, or hit subview (such as pins)
			if hitView != sub || hitView == pin._owner {
				sub.mouseExitedView() // bit hacky, but disable priming this way for mouse exit
				continue
			}

			_pinDropTarget = sub
			sub.mouseEnterView()
			// note: do not break as we may need to unprime other views?
		}
	}

	func onPinUp(pin: LinkPinView, event: NSEvent) {
		if _pinDropTarget == nil {
			print("Dropped pin on empty space.")
			return
		}

		// TODO: Validate target? maybe in here maybe in drag? here is more optimized as drag is currently hacky.

		// handle case of links
		if pin.isNVLink() {
			_undoRedo.execute(cmd: SetLinkDestinationCmd(pin: pin, destination: _pinDropTarget!.Linkable))
			_pinDropTarget = nil
		}
		// handle case of branches
		if pin.isNVBranch() {
			NSMenu.popUpContextMenu(_pinDropMenuBranch, with: event, for: _pinDropTarget!)
		}
		// handle case of switches
		if pin.isNVSwitch() {
			fatalError("Switches not yet supported.")
		}

	}

	@objc func onPinDropBranchTrue() {
		if _pinDropDragged == nil {
			fatalError("Tried to set branch's true destination but _pinDropDragged was nil.")
		}
		if _pinDropTarget == nil {
			fatalError("Tried to set branch's true destination but _pinDropTarget was nil.")
		}
		_undoRedo.execute(cmd: SetBranchDestinationCmd(pin: _pinDropDragged!, destination: _pinDropTarget?.Linkable, trueFalse: true))
		updateCurves()
	}
	@objc func onPinDropBranchFalse() {
		if _pinDropDragged == nil {
			fatalError("Tried to set branch's false destination but _pinDropDragged was nil.")
		}
		if _pinDropTarget == nil {
			fatalError("Tried to set branch's true destination but _pinDropTarget was nil.")
		}
		_undoRedo.execute(cmd: SetBranchDestinationCmd(pin: _pinDropDragged!, destination: _pinDropTarget?.Linkable, trueFalse: false))
		updateCurves()
	}
}
