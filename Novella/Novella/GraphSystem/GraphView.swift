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
	fileprivate let _nvGraph: NVGraph
	fileprivate let _bg: GraphBGView
	fileprivate let _undoRedo: UndoRedo
	fileprivate let _graphBounds: GraphBoundsView
	//
	fileprivate var _allLinkableViews: [LinkableView]
	fileprivate var _allPinViews: [PinView]
	// MARK: Selection
	fileprivate var _marquee: MarqueeView

	fileprivate var _selectionHandler: SelectionHandler?
	// MARK: Gestures
	fileprivate var _panGesture: NSPanGestureRecognizer?
	fileprivate var _contextGesture: NSClickGestureRecognizer?
	// MARK: Linkable Function Variables
	fileprivate var _lastLinkablePanPos: CGPoint
	// MARK: Pin Dropping
	fileprivate var _pinDropTarget: LinkableView?
	fileprivate var _pinDragged: PinView?
	fileprivate var _pinDropBranchMenu: NSMenu // context menu dropping pins for branch pins
	// MARK: Node Context Menu
	fileprivate var _linkableMenu: NSMenu // context menu for linkable widgets
	fileprivate var _contextClickedLinkable: LinkableView?
	// MARK: GraphView Context Menu
	fileprivate var _graphViewMenu: NSMenu // context menu for clicking in the empty graph space
	fileprivate var _lastContextLocation: CGPoint // last point right clicked on graph view
	// MARK: Pin Context Menus
	fileprivate var _linkPinMenu: NSMenu // context menu for clicking on a NVLink pin
	fileprivate var _branchPinMenu: NSMenu // context menu for clicking on a NVBranch pin
	// MARK: Delegate
	fileprivate var _delegate: GraphViewDelegate?
	// MARK: Popovers
	fileprivate var _nodePopovers: [GenericPopover]
	fileprivate var _pinPopovers: [GenericPopover]
	fileprivate var _pinClicked: PinView?
	
	// MARK: - - Initialization -
	init(graph: NVGraph, frameRect: NSRect, visibleRect: NSRect) {
		self._nvGraph = graph
		self._bg = GraphBGView(frame: frameRect)
		self._undoRedo = UndoRedo()
		self._graphBounds = GraphBoundsView(initialBounds: NSMakeSize(visibleRect.width * 0.75, visibleRect.height * 0.75))
		self._graphBounds.frame.origin = NSMakePoint((visibleRect.width - self._graphBounds.Boundary.width)/2, (visibleRect.height - self._graphBounds.Boundary.height)/2)
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
		self._pinDropBranchMenu = NSMenu()
		//
		self._linkableMenu = NSMenu()
		self._contextClickedLinkable = nil
		//
		self._graphViewMenu = NSMenu()
		self._lastContextLocation = CGPoint.zero
		//
		self._linkPinMenu = NSMenu()
		self._branchPinMenu = NSMenu()
		//
		self._nodePopovers = []
		self._pinPopovers = []
		
		super.init(frame: frameRect)
		
		NVStoryManager.shared.addDelegate(self)
		
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
		
		// configure pin branch menu
		_pinDropBranchMenu.addItem(withTitle: "True", action: #selector(GraphView.onPinDropBranchTrue), keyEquivalent: "")
		_pinDropBranchMenu.addItem(withTitle: "False", action: #selector(GraphView.onPinDropBranchFalse), keyEquivalent: "")
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
		
		// configure pin context menus
		_linkPinMenu.addItem(withTitle: "Condition...", action: #selector(GraphView.onLinkPinCondition), keyEquivalent: "")
		_linkPinMenu.addItem(withTitle: "Function...", action: #selector(GraphView.onLinkPinFunction), keyEquivalent: "")
		_branchPinMenu.addItem(withTitle: "Condition...", action: #selector(GraphView.onBranchPinCondition), keyEquivalent: "")
		_branchPinMenu.addItem(withTitle: "Function (true)...", action: #selector(GraphView.onBranchPinFunctionTrue), keyEquivalent: "")
		_branchPinMenu.addItem(withTitle: "Function (false)...", action: #selector(GraphView.onBranchPinFunctionFalse), keyEquivalent: "")
		
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
	
	// MARK: - - Setup -
	fileprivate func rootFor(graph: NVGraph) {
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
		_pinDropTarget = nil
		_pinDragged = nil
		_pinClicked = nil
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
		self._pinPopovers = []
		
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
			guard let node = getLinkableViewFrom(linkable: curr.Origin) else {
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
	
	func getLinkableViewFrom(linkable: NVLinkable?) -> LinkableView? {
		if nil == linkable {
			return nil
		}
		
		return _allLinkableViews.first(where: {
			return $0.Linkable.UUID == linkable?.UUID
		})
	}
}

// MARK: - - Gestures -
extension GraphView {
	// MARK: GraphView Callbacks
	@objc fileprivate func onPan(gesture: NSGestureRecognizer) {
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
	@objc fileprivate func onContextClick(gesture: NSGestureRecognizer) {
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
	func onPanPin(pin: PinView, gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			pin.IsDragging = true
			pin.DragPosition = gesture.location(in: pin)
			pin.redraw()
			_pinDragged = pin
			break
			
		case .changed:
			pin.DragPosition = gesture.location(in: pin)
			pin.redraw()
			
			// figure out which VALID linkable we are hovering - not efficient but it works
			_pinDropTarget = nil
			for curr in _allLinkableViews {
				let pos = gesture.location(in: self) // must be in graph view space as hitTest() is based on superview, which is this
				let hit = curr.hitTest(pos)
				
				// didn't hit, or hit subview (such as a pin)
				if hit != curr || hit == pin.Owner {
					curr.unprime() // bit hacky but disables priming if not valid
					continue
				}
				
				_pinDropTarget = curr
				curr.prime()
			}
			
			break
			
		case .cancelled, .ended:
			pin.IsDragging = false
			pin.redraw()
			
			// unprime as we're done
			_pinDropTarget?.unprime()
			
			// since _pinDropTarget could be nil, this automatically detaches if dragged onto a non-valid node.
			// if i want to change that behavior, i'd just have to manually check nil here
			if let asLink = pin as? PinViewLink {
				_undoRedo.execute(cmd: SetPinLinkDestinationCmd(pin: asLink, destination: _pinDropTarget?.Linkable))
				_pinDragged = nil // no longer dragging anything
			} else
				if let _ = pin as? PinViewBranch {
					if let event = NSApp.currentEvent {
						let forView = _pinDropTarget ?? self
						NSMenu.popUpContextMenu(_pinDropBranchMenu, with: event, for: forView)
					} else {
						print("Tried to open a context menu for dropping a Branch but there was no event available to use.")
					}
				} else {
					print("dropped an unhandled pin type")
			}
			
			break
			
		default:
			print("onPanPin found unexpected gesture state.")
			break
		}
	}
	
	func onContextPin(pin: PinView, gesture: NSClickGestureRecognizer) {
		if let event = NSApp.currentEvent {
			switch pin.BaseLink {
			case is NVLink:
				_pinClicked = pin
				NSMenu.popUpContextMenu(_linkPinMenu, with: event, for: pin)
				
			case is NVBranch:
				_pinClicked = pin
				NSMenu.popUpContextMenu(_branchPinMenu, with: event, for: pin)
				
			default:
				print("Attempted to context click a Pin that doesn't handle context clicking!")
			}
		} else {
			print("Tried to open a context menu for a pin but there was no event available to use.")
		}
	}
}

// MARK: - - Context Menu Callbacks -
extension GraphView {
	// MARK: GraphView Menu
	@objc fileprivate func onGraphViewMenuAddDialog() {
		makeDialog(at: _lastContextLocation)
	}
	@objc fileprivate func onGraphViewMenuAddDelivery() {
		makeDelivery(at: _lastContextLocation)
	}
	@objc fileprivate func onGraphViewMenuAddContext() {
		makeContext(at: _lastContextLocation)
	}
	@objc fileprivate func onGraphViewMenuAddGraph() {
		makeGraph(at: _lastContextLocation)
	}
	
	// MARK: Linkable Menu
	@objc fileprivate func onLinkableMenuAddLink() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a link to a linkable via context but _contextClickedLinkable was nil.")
			return
		}
		let nvLink = NVStoryManager.shared.makeLink(origin: clicked.Linkable)
		// add it to this graph
		do { try _nvGraph.add(link: nvLink) } catch {
			fatalError("Tried to add a new link but couldn't add it to this graph.")
		}
		clicked.addOutput(pin: makePinViewLink(baseLink: nvLink, forNode: clicked))
	}
	@objc fileprivate func onLinkableMenuAddBranch() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a branch to a linkable via context but _contextClickedLinkable was nil.")
			return
		}
		let nvBranch = NVStoryManager.shared.makeBranch(origin: clicked.Linkable)
		// add it to this graph
		do{ try _nvGraph.add(link: nvBranch) } catch {
			fatalError("Tried to add a new branch but couldn't add it to this graph.")
		}
		clicked.addOutput(pin: makePinViewBranch(baseLink: nvBranch, forNode: clicked))
	}
	
	// MARK: PinView Dropping Menu
	@objc fileprivate func onPinDropBranchTrue() {
		guard let draggedPin = _pinDragged else {
			print("Tried to use context menu for dragging a pin but there was no dragged pin found.")
			return
		}
		// should never happen but just in case
		if let asBranchPin = draggedPin as? PinViewBranch {
			_undoRedo.execute(cmd: SetPinBranchDestinationCmd(pin: asBranchPin, destination: _pinDropTarget?.Linkable, forTrue: true))
			_pinDragged = nil // no longer dragging anything
		} else {
			print("Tried to use a context menu dragging a BRANCH pin but the pin wasn't of this type.")
		}
	}
	@objc fileprivate func onPinDropBranchFalse() {
		guard let draggedPin = _pinDragged else {
			print("Tried to use context menu for dragging a pin but there was no dragged pin found.")
			return
		}
		// should never happen but just in case
		if let asBranchPin = draggedPin as? PinViewBranch {
			_undoRedo.execute(cmd: SetPinBranchDestinationCmd(pin: asBranchPin, destination: _pinDropTarget?.Linkable, forTrue: false))
			_pinDragged = nil // no longer dragging anything
		} else {
			print("Tried to use a context menu dragging a BRANCH pin but the pin wasn't of this type.")
		}
	}
	
	// MARK: - - Pin Popovers -
	@objc fileprivate func onLinkPinCondition() {
		guard let pin = _pinClicked else {
			print("Tried to open Condition for a pin but _pinClicked was nil.")
			return
		}
		
		// open popover
		if let existing = _pinPopovers.first(where: {$0 is ConditionPopover && $0.View == _pinClicked}) {
			existing.show(forView: pin, at: .maxX)
		} else {
			let popover = ConditionPopover()
			_pinPopovers.append(popover)
			popover.show(forView: pin, at: .maxX)
			(popover.ViewController as! ConditionPopoverViewController).setCondition(condition: (pin.BaseLink as! NVLink).Condition)
		}
	}
	@objc fileprivate func onLinkPinFunction() {
		guard let pin = _pinClicked else {
			print("Tried to open Function for a pin but _pinClicked was nil.")
			return
		}
		
		// open popover
		if let existing = _pinPopovers.first(where: {$0 is FunctionPopover && $0.View == _pinClicked}) {
			existing.show(forView: pin, at: .maxX)
		} else {
			let popover = FunctionPopover(true)
			_pinPopovers.append(popover)
			popover.show(forView: pin, at: .maxX)
			(popover.ViewController as! FunctionPopoverViewController).setFunction(function: (pin.BaseLink as! NVLink).Transfer.Function)
		}
	}
	@objc fileprivate func onBranchPinCondition() {
		guard let pin = _pinClicked else {
			print("Tried to open Condition for a pin but _pinClicked was nil.")
			return
		}
		
		// open popover
		if let existing = _pinPopovers.first(where: {$0 is ConditionPopover && $0.View == _pinClicked}) {
			existing.show(forView: pin, at: .maxX)
		} else {
			let popover = ConditionPopover()
			_pinPopovers.append(popover)
			popover.show(forView: pin, at: .maxX)
			(popover.ViewController as! ConditionPopoverViewController).setCondition(condition: (pin.BaseLink as! NVBranch).Condition)
		}
	}
	@objc fileprivate func onBranchPinFunctionTrue() {
		guard let pin = _pinClicked else {
			print("Tried to open Condition for a pin but _pinClicked was nil.")
			return
		}
		
		// open popover
		if let existing = _pinPopovers.first(where: {$0 is FunctionPopover && $0.View == _pinClicked && ($0 as! FunctionPopover).TrueFalse}) {
			existing.show(forView: pin, at: .maxX)
		} else {
			let popover = FunctionPopover(true)
			_pinPopovers.append(popover)
			popover.show(forView: pin, at: .maxX)
			(popover.ViewController as! FunctionPopoverViewController).setFunction(function: (pin.BaseLink as! NVBranch).TrueTransfer.Function)
		}
	}
	@objc fileprivate func onBranchPinFunctionFalse() {
		guard let pin = _pinClicked else {
			print("Tried to open Condition for a pin but _pinClicked was nil.")
			return
		}
		
		// open popover
		if let existing = _pinPopovers.first(where: {$0 is FunctionPopover && $0.View == _pinClicked && !($0 as! FunctionPopover).TrueFalse}) {
			existing.show(forView: pin, at: .maxX)
		} else {
			let popover = FunctionPopover(false)
			_pinPopovers.append(popover)
			popover.show(forView: pin, at: .maxX)
			(popover.ViewController as! FunctionPopoverViewController).setFunction(function: (pin.BaseLink as! NVBranch).FalseTransfer.Function)
		}
	}
}

// MARK: - - Selection -
extension GraphView {
	fileprivate func nodeIn(node: LinkableView, rect: NSRect) -> Bool {
		return NSIntersectsRect(node.frame, rect)
	}
	
	fileprivate func allNodesIn(rect: NSRect) -> [LinkableView] {
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
		let nvDialog = NVStoryManager.shared.makeDialog()
		do { try _nvGraph.add(node: nvDialog) } catch {
			// TODO: Possibly handle this by allowing for a remove(node:) in story which removes it from everything?
			fatalError("Tried to add a new dialog but couldn't add it to this graph.")
		}
		return makeDialogLinkableView(nvDialog: nvDialog, at: at)
	}
	
	@discardableResult
	func makeDelivery(at: CGPoint) -> DeliveryLinkableView {
		let nvDelivery = NVStoryManager.shared.makeDelivery()
		do { try _nvGraph.add(node: nvDelivery) } catch {
			fatalError("Tried to add a new delivery but couldn't add it to this graph.")
		}
		return makeDeliveryLinkableView(nvDelivery: nvDelivery, at: at)
	}
	
	@discardableResult
	func makeContext(at: CGPoint) -> ContextLinkableView {
		let nvContext = NVStoryManager.shared.makeContext()
		do { try _nvGraph.add(node: nvContext) } catch {
			fatalError("Tried to add a new context but couldn't add it to this graph.")
		}
		return makeContextLinkableView(nvContext: nvContext, at: at)
	}
	
	@discardableResult
	func makeGraph(at: CGPoint) -> GraphLinkableView {
		let nvGraph = NVStoryManager.shared.makeGraph(name: NSUUID().uuidString)
		do { try _nvGraph.add(graph: nvGraph) } catch {
			fatalError("Tried to add a new graph but couldn't add it to this graph.")
		}
		return makeGraphLinkableView(nvGraph: nvGraph, at: _lastContextLocation)
	}
	
	// MARK: LinkableViews
	@discardableResult
	fileprivate func makeDialogLinkableView(nvDialog: NVDialog, at: CGPoint) -> DialogLinkableView {
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
	fileprivate func makeDeliveryLinkableView(nvDelivery: NVDelivery, at: CGPoint) -> DeliveryLinkableView {
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
	fileprivate func makeContextLinkableView(nvContext: NVContext, at: CGPoint) -> ContextLinkableView {
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
	fileprivate func makeGraphLinkableView(nvGraph: NVGraph, at: CGPoint) -> GraphLinkableView {
		let node = GraphLinkableView(node: nvGraph, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	// MARK: PinViews
	fileprivate func makePinViewLink(baseLink: NVLink, forNode: LinkableView) -> PinViewLink {
		let pin = PinViewLink(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		
		return pin
	}
	fileprivate func makePinViewBranch(baseLink: NVBranch, forNode: LinkableView) -> PinViewBranch {
		let pin = PinViewBranch(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		
		return pin
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


extension GraphView: NVStoryDelegate {
	func onStoryTrashItem(item: NVLinkable) {
		
		for linkTo in NVStoryManager.shared.getLinksTo(item) {
			if let pin = _allPinViews.first(where: {$0.BaseLink == linkTo}) {
				pin.isHidden = true
			}
		}
		
		switch item {
		case is NVDialog:
			if let lv = getLinkableViewFrom(linkable: item as! NVDialog) {
				lv.isHidden = true
			}
			
		default:
			print("Trashed unsupported item: \(item)")
		}
	}
	func onStoryUntrashItem(item: NVLinkable) {
		for linkTo in NVStoryManager.shared.getLinksTo(item) {
			if let pin = _allPinViews.first(where: {$0.BaseLink == linkTo}) {
				pin.isHidden = false
			}
		}
		
		switch item {
		case is NVDialog:
			if let lv = getLinkableViewFrom(linkable: item as! NVDialog) {
				lv.isHidden = false
			}
			
		default:
			print("Trashed unsupported item: \(item)")
		}
	}
}
