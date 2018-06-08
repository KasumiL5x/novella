//
//  GraphView.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphView: NSView {
	// MARK: - - Variables -
	private let _manager: NVStoryManager
	private let _nvGraph: NVGraph
	private let _bg: GraphBGView
	private let _undoRedo: UndoRedo
	//
	private var _allLinkableViews: [LinkableView]
	private var _allPinViews: [PinView]
	// MARK: Selection
	private var _marquee: MarqueeView

	private var _selectionHandler: SelectionHandler?
	// MARK: Gestures
	private var _panGesture: NSPanGestureRecognizer?
	private var _contextGesture: NSClickGestureRecognizer?
	// MARK: Linkable Function Variables
	private var _lastLinkablePanPos: CGPoint
	// MARK: Node Context Menu
	private var _linkableMenu: NSMenu // context menu for linkable widgets
	private var _contextClickedLinkable: LinkableView?
	// MARK: GraphView Context Menu
	private var _graphViewMenu: NSMenu // context menu for clicking in the empty graph space
	private var _lastContextLocation: CGPoint // last point right clicked on graph view
	// MARK: Delegate
	private var _delegate: GraphViewDelegate?
	// MARK: Popovers
	private var _nodePopovers: [GenericPopover]
	
	// MARK: - - Initialization -
	init(manager: NVStoryManager, graph: NVGraph, frameRect: NSRect) {
		self._manager = manager
		self._nvGraph = graph
		self._bg = GraphBGView(frame: frameRect)
		self._undoRedo = UndoRedo()
		//
		self._allLinkableViews = []
		self._allPinViews = []
		//
		self._marquee = MarqueeView(frame: frameRect)
		self._selectionHandler = nil
		//
		self._panGesture = nil
		self._contextGesture = nil
		//
		self._lastLinkablePanPos = CGPoint.zero
		//
		self._linkableMenu = NSMenu()
		self._contextClickedLinkable = nil
		//
		self._graphViewMenu = NSMenu()
		self._lastContextLocation = CGPoint.zero
		//
		self._nodePopovers = []
		
		super.init(frame: frameRect)
		
		_manager.addDelegate(self)
		
		// selection handler
		self._selectionHandler = SelectionHandler(graph: self)
		
		// configure pan gesture
		self._panGesture = NSPanGestureRecognizer(target: self, action: #selector(GraphView.onPan))
		self._panGesture!.buttonMask = 0x1 // "primary button"
		self.addGestureRecognizer(self._panGesture!)
		// configure context gesture
		self._contextGesture = NSClickGestureRecognizer(target: self, action: #selector(GraphView.onContextClick))
		self._contextGesture!.buttonMask = 0x2 // "secondary button"
		self._contextGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(self._contextGesture!)
		
		// configure linkable menu
		_linkableMenu.addItem(withTitle: "Add Link", action: #selector(GraphView.onLinkableMenuAddLink), keyEquivalent: "")
		_linkableMenu.addItem(withTitle: "Add Branch", action: #selector(GraphView.onLinkableMenuAddBranch), keyEquivalent: "")
		// configure graphview menu
		let addSubMenu = NSMenu()
		addSubMenu.addItem(withTitle: "Dialog", action: #selector(GraphView.onGraphViewMenuAddDialog), keyEquivalent: "")
		addSubMenu.addItem(withTitle: "Delivery", action: #selector(GraphView.onGraphViewMenuAddDelivery), keyEquivalent: "")
		addSubMenu.addItem(withTitle: "Context", action: #selector(GraphView.onGraphViewMenuAddContext), keyEquivalent: "")
		addSubMenu.addItem(withTitle: "Graph", action: #selector(GraphView.onGraphViewMenuAddGraph), keyEquivalent: "")
		let addMenu = NSMenuItem()
		addMenu.title = "Add..."
		addMenu.submenu = addSubMenu
		_graphViewMenu.addItem(addMenu)
		_graphViewMenu.addItem(withTitle: "Un/Trash Selection", action: #selector(GraphView.onGraphViewMenuTrashSelection), keyEquivalent: "")
		_graphViewMenu.addItem(withTitle: "Empty Trash", action: #selector(GraphView.onGraphViewMenuEmptyTrash), keyEquivalent: "")
		
		rootFor(graph: _nvGraph)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphView::init(coder) not implemented.")
	}
	
	// MARK: - - Properties -
	var NovellaGraph: NVGraph {
		get{ return _nvGraph }
	}
	var Delegate: GraphViewDelegate? {
		get{ return _delegate }
		set{
			_delegate = newValue
			_selectionHandler?.Delegate = Delegate
		}
	}
	var Undo: UndoRedo {
		get{ return _undoRedo }
	}
	
	// MARK: - - Setup -
	private func rootFor(graph: NVGraph) {
		// remove existing views
		self.subviews.removeAll()
		
		// add background
		self.addSubview(_bg)
		// add graph bounds above bg but below everything else
//		self.addSubview(_graphBounds)
		// add marquee view (must be last; others add after it)
		self.addSubview(_marquee)
		
		// remove selection
		_selectionHandler?.select([], append: false)
		
		// reset some other things
		_lastLinkablePanPos = CGPoint.zero
		_contextClickedLinkable = nil
		_lastContextLocation = CGPoint.zero
		
		// clear undo/redo
		_undoRedo.clear()
		
		// clear existing linkable views
		_allLinkableViews = []
		// clear existing pin views
		_allPinViews = []
		
		// clear all popovers
		self._nodePopovers = []
		
		// load all nodes
		for curr in graph.Nodes {
			switch curr {
			case is NVDialog:
				let node = DialogLinkableView(node: curr as! NVDialog, graphView: self)
				_allLinkableViews.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			case is NVDelivery:
				let node = DeliveryLinkableView(node: curr as! NVDelivery, graphView: self)
				_allLinkableViews.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			case is NVContext:
				let node = ContextLinkableView(node: curr as! NVContext, graphView: self)
				_allLinkableViews.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			default:
				print("Not implemented node type \(curr).")
				break
			}
		}
		// load all subgraph (nodes)
		for curr in graph.Graphs {
			let node = GraphLinkableView(node: curr, graphView: self)
			_allLinkableViews.append(node)
			self.addSubview(node, positioned: .below, relativeTo: _marquee)
		}
		// load all links
		for curr in graph.Links {
			guard let node = getLinkableViewFrom(linkable: curr.Origin, includeParentGraphs: false) else {
				print("Received a link with an origin that could not be found!")
				continue
			}
			
			switch curr {
			case is NVLink:
				node.addOutput(pin: makePinViewLink(baseLink: curr as! NVLink, forNode: node))
				break
			case is NVBranch:
				node.addOutput(pin: makePinViewBranch(baseLink: curr as! NVBranch, forNode: node))
				break
			default:
				print("Found a link that is not yet supported (\(curr)).")
				break
			}
		}
	}
	
	// MARK: - - Graph Functions / Helpers -
	func offsetToEditorPosition(pos: CGPoint) -> CGPoint {
		return pos - NSMakePoint(bounds.width*0.5, bounds.height*0.5)
	}
	func offsetFromEditorPosition(pos: CGPoint) -> CGPoint {
		return pos + NSMakePoint(bounds.width*0.5, bounds.height*0.5)
	}
	
	func screenshot() -> NSImage? {
		let img = NSImage(size: visibleRect.size)
		img.lockFocus()
		if lockFocusIfCanDraw() {
			displayIgnoringOpacity(visibleRect, in: NSGraphicsContext.current!)
			unlockFocus()
		}
		img.unlockFocus()
		
		return img
	}
	
	func selectedBounds() -> NSRect {
		if _selectionHandler!.Selection.isEmpty {
			return NSRect.zero
		}
		
		// get bounds of selection as a rect
		var minX = CGFloat.infinity
		var minY = CGFloat.infinity
		var maxX = -CGFloat.infinity
		var maxY = -CGFloat.infinity
		for curr in _selectionHandler!.Selection {
			minX = curr.frame.minX < minX ? curr.frame.minX : minX
			maxX = curr.frame.maxX > maxX ? curr.frame.maxX : maxX
			minY = curr.frame.minY < minY ? curr.frame.minY : minY
			maxY = curr.frame.maxY > maxY ? curr.frame.maxY : maxY
		}
		return NSMakeRect(minX, minY, maxX - minX, maxY - minY)
	}
	
	func updateCurves() {
		for child in _allPinViews {
			child.redraw()
		}
	}
	
	func undo(levels: Int=1) {
		_undoRedo.undo(levels: levels)
	}
	func redo(levels: Int=1) {
		_undoRedo.redo(levels: levels)
	}
	
	func getLinkableViewFrom(linkable: NVLinkable?, includeParentGraphs: Bool) -> LinkableView? {
		if nil == linkable {
			return nil
		}
		
		return _allLinkableViews.first(where: {
			if includeParentGraphs && $0 is GraphLinkableView {
				let asGraph = (($0 as! GraphLinkableView).Linkable as! NVGraph)
				for child in asGraph.Nodes {
					if child.UUID == linkable?.UUID {
						return true
					}
				}
			}
			return $0.Linkable.UUID == linkable?.UUID
		})
	}
}

// MARK: - - Gestures -
extension GraphView {
	// MARK: GraphView Callbacks
	@objc private func onPan(gesture: NSGestureRecognizer) {
		switch gesture.state {
		case .began:
			if !_marquee.InMarquee {
				_marquee.Origin = gesture.location(in: self)
				_marquee.InMarquee = true
			}
			break
			
		case .changed:
			if _marquee.InMarquee {
				let curr = gesture.location(in: self)
				_marquee.Marquee.origin = NSMakePoint(fmin(_marquee.Origin.x, curr.x), fmin(_marquee.Origin.y, curr.y))
				_marquee.Marquee.size = NSMakeSize(fabs(curr.x - _marquee.Origin.x), fabs(curr.y - _marquee.Origin.y))
				
				// handle priming
				let nodesInMarquee = allNodesIn(rect: _marquee.Marquee)
				for curr in _allLinkableViews {
					if curr.IsSelected {
						continue // ignore already selected
					}
					
					if nodesInMarquee.contains(curr) {
						curr.prime()
					} else {
						curr.unprime()
					}
				}
			}
			break
			
		case .cancelled, .ended:
			if _marquee.InMarquee {
				if NSApp.currentEvent!.modifierFlags.contains(.shift) {
					_undoRedo.execute(cmd: SelectNodesCmd(selection: allNodesIn(rect: _marquee.Marquee), handler: _selectionHandler!))
				} else {
					_undoRedo.execute(cmd: ReplacedSelectedNodesCmd(selection: allNodesIn(rect: _marquee.Marquee), handler: _selectionHandler!))
				}
				_marquee.Marquee = NSRect.zero
				_marquee.InMarquee = false
			}
			break
			
		default:
			print("In unexpected pan state.")
			break
		}
	}
	@objc private func onContextClick(gesture: NSGestureRecognizer) {
		if let event = NSApp.currentEvent {
			_lastContextLocation = gesture.location(in: self)
			NSMenu.popUpContextMenu(_graphViewMenu, with: event, for: self)
		} else {
			print("Tried to open a context menu for the graph view but there was no event available to use.")
		}
	}
	
	// MARK: From LinkableView
	func onClickLinkable(node: LinkableView, gesture: NSGestureRecognizer) {
		let append = NSApp.currentEvent!.modifierFlags.contains(.shift)
		if append {
			if node.IsSelected {
				_undoRedo.execute(cmd: DeselectNodesCmd(selection: [node], handler: _selectionHandler!))
			} else {
				_undoRedo.execute(cmd: SelectNodesCmd(selection: [node], handler: _selectionHandler!))
			}
		} else {
			_undoRedo.execute(cmd: ReplacedSelectedNodesCmd(selection: [node], handler: _selectionHandler!))
		}
	}
	func onDoubleClickLinkable(node: LinkableView, gesture: NSGestureRecognizer) {
		// just reshow existing if it already exists
		if let existing = _nodePopovers.first(where: {$0.View == node}) {
			existing.show(forView: node, at: .minY)
			return
		}
		
		switch node {
		case is DialogLinkableView:
			let popover = DialogPopover()
			_nodePopovers.append(popover)
			popover.show(forView: node, at: .minY)
			(popover.ViewController as! DialogPopoverViewController).setDialogNode(node: node as! DialogLinkableView)
			
		case is DeliveryLinkableView:
			let popover = DeliveryPopover()
			_nodePopovers.append(popover)
			popover.show(forView: node, at: .minY)
			(popover.ViewController as! DeliveryPopoverViewController).setDeliveryNode(node: node as! DeliveryLinkableView)
			
		case is ContextLinkableView:
			let popover = ContextPopover()
			_nodePopovers.append(popover)
			popover.show(forView: node, at: .minY)
			(popover.ViewController as! ContextPopoverViewController).setContextNode(node: node as! ContextLinkableView)
			
		default:
			print("Double clicked a LinkableView that doesn't support popovers.")
		}
	}
	func onPanLinkable(node: LinkableView, gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			// if node is not selected but we dragged it, replace selection and then start dragging
			if !node.IsSelected {
				_undoRedo.execute(cmd: ReplacedSelectedNodesCmd(selection: [node], handler: _selectionHandler!))
			}
			
			_lastLinkablePanPos = gesture.location(in: self)
			if _undoRedo.inCompound() {
				print("Tried to begin pan LinkableView but UndoRedo was already in a Compound!")
			} else {
				_undoRedo.beginCompound(executeOnAdd: true)
			}
			break
		case .changed:
			let curr = gesture.location(in: self)
			let dx = (curr.x - _lastLinkablePanPos.x)
			let dy = (curr.y - _lastLinkablePanPos.y)
			
			_selectionHandler?.Selection.forEach({
				var pos = NSMakePoint($0.frame.origin.x + dx, $0.frame.origin.y + dy)
				// clamp to bounds
				if pos.x < 0.0 {
					pos.x = 0
				}
				if pos.y < 0.0 {
					pos.y = 0.0
				}
				if (pos.y + $0.frame.height) > bounds.height {
					pos.y = bounds.height - $0.frame.height
				}
				if (pos.x + $0.frame.width) > bounds.width {
					pos.x = bounds.width - $0.frame.width
				}
				_undoRedo.execute(cmd: MoveLinkableViewCmd(node: $0, from: $0.frame.origin, to: pos))
			})
			
			_lastLinkablePanPos = curr
			break
		case .cancelled, .ended:
			if !_undoRedo.inCompound() {
				print("Tried to end pan LinkableView but UndoRedo was not in a Compound!")
			} else {
				_undoRedo.endCompound()
			}
			break
		default:
			print("onPanLinkable found unexpected gesture state.")
			break
		}
	}
	func onContextLinkable(node: LinkableView, gesture: NSGestureRecognizer) {
		if let event = NSApp.currentEvent {
			_contextClickedLinkable = node
			NSMenu.popUpContextMenu(_linkableMenu, with: event, for: node)
		} else {
			print("Tried to open a context menu for a linkable but there was no event available to use.")
		}
	}
	
	// MARK: From PinView
	func linkableViewAtPoint(_ point: CGPoint) -> LinkableView? {
		for curr in _allLinkableViews {
			let hit = curr.hitTest(point)
		
			// didn't hit or hit a subview
			if hit != curr {
				continue
			}
			
			return curr
		}
		return nil
	}
}

// MARK: - - Context Menu Callbacks -
extension GraphView {
	// MARK: GraphView Menu
	@objc private func onGraphViewMenuAddDialog() {
		makeDialog(at: _lastContextLocation)
	}
	@objc private func onGraphViewMenuAddDelivery() {
		makeDelivery(at: _lastContextLocation)
	}
	@objc private func onGraphViewMenuAddContext() {
		makeContext(at: _lastContextLocation)
	}
	@objc private func onGraphViewMenuAddGraph() {
		makeGraph(at: _lastContextLocation)
	}
	@objc private func onGraphViewMenuTrashSelection() {
		for curr in _selectionHandler!.Selection {
			let inTrash = curr.Linkable.Trashed
			var linkable = curr.Linkable
			linkable.Trashed = !inTrash
		}
	}
	@objc private func onGraphViewMenuEmptyTrash() {
		_manager.emptyTrash()
	}
	
	// MARK: Linkable Menu
	@objc private func onLinkableMenuAddLink() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a link to a linkable via context but _contextClickedLinkable was nil.")
			return
		}
		let nvLink = _manager.makeLink(origin: clicked.Linkable)
		// add it to this graph
		do { try _nvGraph.add(link: nvLink) } catch {
			fatalError("Tried to add a new link but couldn't add it to this graph.")
		}
		clicked.addOutput(pin: makePinViewLink(baseLink: nvLink, forNode: clicked))
	}
	@objc private func onLinkableMenuAddBranch() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a branch to a linkable via context but _contextClickedLinkable was nil.")
			return
		}
		let nvBranch = _manager.makeBranch(origin: clicked.Linkable)
		// add it to this graph
		do{ try _nvGraph.add(link: nvBranch) } catch {
			fatalError("Tried to add a new branch but couldn't add it to this graph.")
		}
		clicked.addOutput(pin: makePinViewBranch(baseLink: nvBranch, forNode: clicked))
	}
}

// MARK: - - Selection -
extension GraphView {
	func selectNVLinkable(linkable: NVLinkable) {
		if let view = getLinkableViewFrom(linkable: linkable, includeParentGraphs: false) {
			_undoRedo.execute(cmd: ReplacedSelectedNodesCmd(selection: [view], handler: _selectionHandler!))
		}
	}
	
	private func nodeIn(node: LinkableView, rect: NSRect) -> Bool {
		return NSIntersectsRect(node.frame, rect)
	}
	
	private func allNodesIn(rect: NSRect) -> [LinkableView] {
		var nodes: [LinkableView] = []
		for curr in _allLinkableViews {
			if nodeIn(node: curr, rect: rect) {
				nodes.append(curr)
			}
		}
		return nodes
	}
}

// MARK: - - Creation -
extension GraphView {
	// MARK: LinkableView Conveniences
	@discardableResult
	func makeDialog(at: CGPoint) -> DialogLinkableView {
		let nvDialog = _manager.makeDialog()
		do { try _nvGraph.add(node: nvDialog) } catch {
			// TODO: Possibly handle this by allowing for a remove(node:) in story which removes it from everything?
			fatalError("Tried to add a new dialog but couldn't add it to this graph.")
		}
		return makeDialogLinkableView(nvDialog: nvDialog, at: at)
	}
	
	@discardableResult
	func makeDelivery(at: CGPoint) -> DeliveryLinkableView {
		let nvDelivery = _manager.makeDelivery()
		do { try _nvGraph.add(node: nvDelivery) } catch {
			fatalError("Tried to add a new delivery but couldn't add it to this graph.")
		}
		return makeDeliveryLinkableView(nvDelivery: nvDelivery, at: at)
	}
	
	@discardableResult
	func makeContext(at: CGPoint) -> ContextLinkableView {
		let nvContext = _manager.makeContext()
		do { try _nvGraph.add(node: nvContext) } catch {
			fatalError("Tried to add a new context but couldn't add it to this graph.")
		}
		return makeContextLinkableView(nvContext: nvContext, at: at)
	}
	
	@discardableResult
	func makeGraph(at: CGPoint) -> GraphLinkableView {
		let nvGraph = _manager.makeGraph(name: NSUUID().uuidString)
		do { try _nvGraph.add(graph: nvGraph) } catch {
			fatalError("Tried to add a new graph but couldn't add it to this graph.")
		}
		return makeGraphLinkableView(nvGraph: nvGraph, at: at)
	}
	
	// MARK: LinkableViews
	@discardableResult
	private func makeDialogLinkableView(nvDialog: NVDialog, at: CGPoint) -> DialogLinkableView {
		let node = DialogLinkableView(node: nvDialog, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeDeliveryLinkableView(nvDelivery: NVDelivery, at: CGPoint) -> DeliveryLinkableView {
		let node = DeliveryLinkableView(node: nvDelivery, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeContextLinkableView(nvContext: NVContext, at: CGPoint) -> ContextLinkableView {
		let node = ContextLinkableView(node: nvContext, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeGraphLinkableView(nvGraph: NVGraph, at: CGPoint) -> GraphLinkableView {
		let node = GraphLinkableView(node: nvGraph, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	private func deleteLinkableView(node: LinkableView) {
		// 1. remove from parent view
		node.removeFromSuperview()
		
		// 2. remove all of its pins (as we need to remove them from lists and can't rely on auto remove)
		node.Outputs.forEach { (pin) in
			deletePinView(pin: pin)
		}
		
		// 3. remove from all linkables
		_allLinkableViews.remove(at: _allLinkableViews.index(of: node)!)
		
		// 4. update all curves as anything incoming no longer links to this item
		updateCurves() // TODO: Could optimize by only redrawing the connected curves
	}
	
	// MARK: PinViews
	private func makePinViewLink(baseLink: NVLink, forNode: LinkableView) -> PinViewLink {
		let pin = PinViewLink(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		
		return pin
	}
	private func makePinViewBranch(baseLink: NVBranch, forNode: LinkableView) -> PinViewBranch {
		let pin = PinViewBranch(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		
		return pin
	}
	
	private func deletePinView(pin: PinView) {
		// 1. remove from parent view
		pin.removeFromSuperview()
		
		// 2. remove from linkable's list
		_allLinkableViews.forEach { (lview) in
			if lview.Outputs.contains(pin) {
				lview.removeOutput(pin: pin)
			}
		}
		
		// 3. remove from all pin views
		_allPinViews.remove(at: _allPinViews.index(of: pin)!)
		
		// 4. update all curves as anything incoming no longer links to this item
		updateCurves() // TODO: Could optimize by only redrawing the connected curves
	}
}

// MARK: - - NSPopoverDelegate -
extension GraphView: NSPopoverDelegate {
	func detachableWindow(for popover: NSPopover) -> NSWindow? {
		return nil // this uses the default window; if i return my own NSWindow here it will use that instead.
	}
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
}


// MARK: - - NVStoryDelegate -
extension GraphView: NVStoryDelegate {
	func onStoryTrashItem(item: NVLinkable) {

		/* decided not to trash incoming links as you may want to reuse them
		for linkTo in NVStoryManager.shared.getLinksTo(item) {
			if let pin = _allPinViews.first(where: {$0.BaseLink == linkTo}) {
				pin.TrashMode = true
			}
		}
		*/
		
		switch item {
		case is NVDialog:
			fallthrough
		case is NVDelivery:
			fallthrough
		case is NVContext:
			if let lv = getLinkableViewFrom(linkable: item, includeParentGraphs: false) {
				lv.Trashed = true
			}
			
		default:
			print("Trashed unsupported item: \(item)")
		}
	}
	func onStoryUntrashItem(item: NVLinkable) {
		for linkTo in _manager.getLinksTo(item) {
			if let pin = _allPinViews.first(where: {$0.BaseLink == linkTo}) {
				pin.TrashMode = false
			}
		}
		
		switch item {
		case is NVDialog:
			fallthrough
		case is NVDelivery:
			fallthrough
		case is NVContext:
			if let lv = getLinkableViewFrom(linkable: item, includeParentGraphs: false) {
				lv.Trashed = false
			}
			
		default:
			print("Trashed unsupported item: \(item)")
		}
	}
	
	func onStoryDeleteLink(link: NVBaseLink) {
		if let pin = _allPinViews.first(where: {$0.BaseLink == link}) {
			deletePinView(pin: pin)
		}
	}
	func onStoryDeleteNode(node: NVNode) {
		if let node = _allLinkableViews.first(where: {$0.Linkable.UUID == node.UUID}) {
			deleteLinkableView(node: node)
		}
	}
}
