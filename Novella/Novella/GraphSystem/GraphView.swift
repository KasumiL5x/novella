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
	private let _document: NovellaDocument
	private var _nvGraph: NVGraph
	private let _bg: GraphBGView
	//
	private var _allNodes: [Node]
	private var _allPinViews: [PinView]
	// MARK: Selection
	private var _marquee: MarqueeView

	private var _selectionHandler: SelectionHandler?
	// MARK: Gestures
	private var _panGesture: NSPanGestureRecognizer?
	private var _rmbPanGesture: NSPanGestureRecognizer?
	private var _rmbPanLocation: CGPoint
	private var _contextGesture: NSClickGestureRecognizer?
	// MARK: Node Function Variables
	private var _lastNodePanPos: CGPoint
	// MARK: GraphView Context Menu
	private var _graphViewMenu: NSMenu // context menu for clicking in the empty graph space
	private var _lastContextLocation: CGPoint // last point right clicked on graph view
	// MARK: Delegate
	private var _delegate: GraphViewDelegate?
	
	// MARK: - - Initialization -
	init(doc: NovellaDocument, graph: NVGraph, frameRect: NSRect) {
		self._document = doc
		self._nvGraph = graph
		self._bg = GraphBGView(frame: frameRect)
		//
		self._allNodes = []
		self._allPinViews = []
		//
		self._marquee = MarqueeView(frame: frameRect)
		self._selectionHandler = nil
		//
		self._panGesture = nil
		self._rmbPanGesture = nil
		self._rmbPanLocation = CGPoint.zero
		self._contextGesture = nil
		//
		self._lastNodePanPos = CGPoint.zero
		//
		self._graphViewMenu = NSMenu()
		self._lastContextLocation = CGPoint.zero
		
		super.init(frame: frameRect)
		
		_document.Manager.addDelegate(self)
		
		// selection handler
		self._selectionHandler = SelectionHandler(graph: self)
		
		// configure pan gesture
		self._panGesture = NSPanGestureRecognizer(target: self, action: #selector(GraphView.onPan))
		self._panGesture!.buttonMask = 0x1 // "primary button"
		self.addGestureRecognizer(self._panGesture!)
		// configure rmb pan gesture
		self._rmbPanGesture = NSPanGestureRecognizer(target: self, action: #selector(GraphView.onRmbPan))
		self._rmbPanGesture!.buttonMask = 0x2 // "secondary button"
		self.addGestureRecognizer(self._rmbPanGesture!)
		// configure context gesture
		self._contextGesture = NSClickGestureRecognizer(target: self, action: #selector(GraphView.onContextClick))
		self._contextGesture!.buttonMask = 0x2 // "secondary button"
		self._contextGesture!.numberOfClicksRequired = 1
		self.addGestureRecognizer(self._contextGesture!)
		
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
		//
		let selectSubMenu = NSMenu()
		selectSubMenu.addItem(withTitle: "Add link", action: #selector(GraphView.addLinkToSelectedNodes), keyEquivalent: "")
		selectSubMenu.addItem(withTitle: "Add Branch", action: #selector(GraphView.addBranchToSelectedNodes), keyEquivalent: "")
		let selectMenu = NSMenuItem()
		selectMenu.title = "Selection..."
		selectMenu.submenu = selectSubMenu
		_graphViewMenu.addItem(selectMenu)
		
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
		get{ return _document.Undo }
	}
	var Manager: NVStoryManager {
		get{ return _document.Manager }
	}
	var Document: NovellaDocument {
		get{ return _document }
	}
	
	// MARK: - - Setup -
	func rootFor(graph: NVGraph) {
		// remove existing views
		self.subviews.removeAll()
		
		// add background
		self.addSubview(_bg)
		// add marquee view (must be last; others add after it)
		self.addSubview(_marquee)
		
		// remove selection
		_selectionHandler?.select([], append: false)
		
		// reset some other things
		_lastNodePanPos = CGPoint.zero
		_lastContextLocation = CGPoint.zero
		
		// clear undo/redo TODO: Not sure if this should still be done since it's not graph-based now.
		_document.Undo.clear()
		
		// clear existing node views
		_allNodes = []
		// clear existing pin views
		_allPinViews = []
		
		// store new graph
		_nvGraph = graph
		
		// load all nodes
		for curr in graph.Nodes {
			switch curr {
			case is NVDialog:
				let node = DialogNode(node: curr as! NVDialog, graphView: self)
				_allNodes.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			case is NVDelivery:
				let node = DeliveryNode(node: curr as! NVDelivery, graphView: self)
				_allNodes.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			case is NVContext:
				let node = ContextNode(node: curr as! NVContext, graphView: self)
				_allNodes.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				
			default:
				print("Not implemented node type \(curr).")
				break
			}
		}
		// load all subgraph (nodes)
		for curr in graph.Graphs {
			let node = GraphNode(node: curr, graphView: self)
			_allNodes.append(node)
			self.addSubview(node, positioned: .below, relativeTo: _marquee)
		}
		// load all links
		for curr in graph.Links {
			guard let node = getNodeFrom(object: curr.Origin, includeParentGraphs: false) else {
				print("Received a link with an origin that could not be found!")
				continue
			}
			
			switch curr {
			case is NVLink:
				node.addOutput(pin: makePinViewLink(baseLink: curr as! NVLink, forNode: node))
				
			case is NVBranch:
				node.addOutput(pin: makePinViewBranch(baseLink: curr as! NVBranch, forNode: node))
				
			case is NVSwitch:
				node.addOutput(pin: makePinViewSwitch(baseLink: curr as! NVSwitch, forNode: node))
				
			default:
				print("Found a link that is not yet supported (\(curr)).")
				
			}
		}
	}
	
	// MARK: - - Graph Functions / Helpers -
	override func mouseDown(with event: NSEvent) {
		_selectionHandler?.select([], append: false)
	}
	func redrawAll() {
		self.setNeedsDisplay(bounds)
		_allNodes.forEach{$0.redraw()}
		_allPinViews.forEach{$0.redraw()}
	}
	func offsetToEditorPosition(pos: CGPoint) -> CGPoint {
		return pos - NSMakePoint(bounds.width*0.5, bounds.height*0.5)
	}
	func offsetFromEditorPosition(pos: CGPoint) -> CGPoint {
		return pos + NSMakePoint(bounds.width*0.5, bounds.height*0.5)
	}
	
	func screenshot() -> NSImage? {
			let rect = NSMakeRect(visibleRect.origin.x, visibleRect.origin.y, visibleRect.width, visibleRect.height)
			let img = NSImage(size: rect.size)
			img.lockFocus()
			if lockFocusIfCanDraw() {
				NSGraphicsContext.saveGraphicsState()
				NSGraphicsContext.current?.cgContext.translateBy(x: -visibleRect.origin.x, y: -visibleRect.origin.y)
				displayIgnoringOpacity(rect, in: NSGraphicsContext.current!)
				NSGraphicsContext.restoreGraphicsState()
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
	func contentBounds() -> NSRect {
		if _allNodes.isEmpty {
			return NSRect.zero
		}
		
		// get bounds of selection as a rect
		var minX = CGFloat.infinity
		var minY = CGFloat.infinity
		var maxX = -CGFloat.infinity
		var maxY = -CGFloat.infinity
		for curr in _allNodes {
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
		_document.Undo.undo(levels: levels)
	}
	func redo(levels: Int=1) {
		_document.Undo.redo(levels: levels)
	}
	
	func getNodeFrom(object: NVObject?, includeParentGraphs: Bool) -> Node? {
		if nil == object {
			return nil
		}
		
		return _allNodes.first(where: {
			if includeParentGraphs && $0 is GraphNode {
				let asGraph = (($0 as! GraphNode).Object as! NVGraph)
				for child in asGraph.Nodes {
					if child.UUID == object?.UUID {
						return true
					}
				}
			}
			return $0.Object.UUID == object?.UUID
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
				for curr in _allNodes {
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
					_selectionHandler?.select(allNodesIn(rect: _marquee.Marquee), append: true)
				} else {
					_selectionHandler?.select(allNodesIn(rect: _marquee.Marquee), append: false)
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
	@objc private func onRmbPan(gesture: NSGestureRecognizer) {
		// if embedded in a scrollview, super is NSClipView,
		guard let scrollView = superview?.superview as? NSScrollView else {
			print("Attempted to RMB pan the GraphView but it was not correctly embedded in an NSScrollView.")
			return
		}
		
		switch gesture.state {
		case .began:
			_rmbPanLocation = gesture.location(in: scrollView)
			
		case .changed:
			let curr = gesture.location(in: scrollView)
			
			let panSpeed: CGFloat = 0.5 // speed of pan relative to delta
			var diff = (curr - _rmbPanLocation) * panSpeed
			// flip to match default trackpad behavior
			diff.x *= scrollView.isFlipped ? -1.0 : 1.0
			diff.y *= scrollView.isFlipped ? 1.0 : -1.0

			let center = visibleRect.origin + diff
			scrollView.contentView.scroll(to: center)
			scrollView.reflectScrolledClipView(scrollView.contentView)

			
			_rmbPanLocation = curr
			
		default:
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
	
	// MARK: From Node
	func onClickNode(node: Node, gesture: NSGestureRecognizer) {
		let append = NSApp.currentEvent!.modifierFlags.contains(.shift)
		if append {
			if node.IsSelected {
				_selectionHandler?.deselect([node])
			} else {
				_selectionHandler?.select([node], append: true)
			}
		} else {
			_selectionHandler?.select([node], append: false)
		}
	}
	func onPanNode(node: Node, gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			// if node is not selected but we dragged it, replace selection and then start dragging
			if !node.IsSelected {
				_selectionHandler?.select([node], append: false)
			}
			
			_lastNodePanPos = gesture.location(in: self)
			if _document.Undo.inCompound() {
				print("Tried to begin panning a Node but UndoRedo was already in a Compound!")
			} else {
				_document.Undo.beginCompound(executeOnAdd: true)
			}
			break
		case .changed:
			let curr = gesture.location(in: self)
			let dx = (curr.x - _lastNodePanPos.x)
			let dy = (curr.y - _lastNodePanPos.y)
			
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
				_document.Undo.execute(cmd: MoveNodeCmd(node: $0, from: $0.frame.origin, to: pos))
			})
			
			_lastNodePanPos = curr
			break
		case .cancelled, .ended:
			if !_document.Undo.inCompound() {
				print("Tried to end panning a Node but UndoRedo was not in a Compound!")
			} else {
				_document.Undo.endCompound()
			}
			break
		default:
			print("onPanNode found unexpected gesture state.")
			break
		}
	}
	
	// MARK: From PinView
	func nodeAtPoint(_ point: CGPoint) -> Node? {
		for curr in _allNodes {
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
}

// MARK: - - Selection -
extension GraphView {
	func selectNode(object: NVObject) {
		if let view = getNodeFrom(object: object, includeParentGraphs: false) {
			_selectionHandler?.select([view], append: false)
		}
	}
	
	private func nodeIn(node: Node, rect: NSRect) -> Bool {
		return NSIntersectsRect(node.frame, rect)
	}
	
	private func allNodesIn(rect: NSRect) -> [Node] {
		var nodes: [Node] = []
		for curr in _allNodes {
			if nodeIn(node: curr, rect: rect) {
				nodes.append(curr)
			}
		}
		return nodes
	}
}

// MARK: - - Creation -
extension GraphView {
	// MARK: Node Conveniences
	func makeDialog(at: CGPoint) {
		let nvDialog = _document.Manager.makeDialog()
		nvDialog.Position = at
		_nvGraph.add(node: nvDialog)
	}
	
	func makeDelivery(at: CGPoint) {
		let nvDelivery = _document.Manager.makeDelivery()
		nvDelivery.Position = at
		_nvGraph.add(node: nvDelivery)
	}
	
	func makeContext(at: CGPoint) {
		let nvContext = _document.Manager.makeContext()
		nvContext.Position = at
		_nvGraph.add(node: nvContext)
	}
	
	func makeGraph(at: CGPoint) {
		let nvGraph = _document.Manager.makeGraph(name: NSUUID().uuidString)
		nvGraph.Position = at
		_nvGraph.add(graph: nvGraph)
	}
	
	// MARK: Nodes
	@discardableResult
	private func makeDialogNode(nvDialog: NVDialog, at: CGPoint) -> DialogNode {
		let node = DialogNode(node: nvDialog, graphView: self)
		_allNodes.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeDeliveryNode(nvDelivery: NVDelivery, at: CGPoint) -> DeliveryNode {
		let node = DeliveryNode(node: nvDelivery, graphView: self)
		_allNodes.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeContextNode(nvContext: NVContext, at: CGPoint) -> ContextNode {
		let node = ContextNode(node: nvContext, graphView: self)
		_allNodes.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	@discardableResult
	private func makeGraphNode(nvGraph: NVGraph, at: CGPoint) -> GraphNode {
		let node = GraphNode(node: nvGraph, graphView: self)
		_allNodes.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= node.frame.width/2
		pos.y -= node.frame.height/2
		node.move(to: pos)
		
		return node
	}
	
	private func deleteNode(node: Node) {
		// 1. remove from parent view
		node.removeFromSuperview()
		
		// 2. remove all of its pins (as we need to remove them from lists and can't rely on auto remove)
		node.Outputs.forEach { (pin) in
			deletePinView(pin: pin)
		}
		
		// 3. remove from all nodes
		_allNodes.remove(at: _allNodes.index(of: node)!)
		
		// 4. update all curves as anything incoming no longer links to this item
		updateCurves() // TODO: Could optimize by only redrawing the connected curves
	}
	
	// MARK: PinViews
	private func makePinViewLink(baseLink: NVLink, forNode: Node) -> PinViewLink {
		let pin = PinViewLink(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		return pin
	}
	private func makePinViewBranch(baseLink: NVBranch, forNode: Node) -> PinViewBranch {
		let pin = PinViewBranch(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		return pin
	}
	private func makePinViewSwitch(baseLink: NVSwitch, forNode: Node) -> PinViewSwitch {
		let pin = PinViewSwitch(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		return pin
	}
	
	private func deletePinView(pin: PinView) {
		// 1. remove from nodes
		_allNodes.forEach { (lview) in
			if lview.Outputs.contains(pin) {
				lview.removeOutput(pin: pin)
			}
		}
		
		// 2. remove from all pin views
		_allPinViews.remove(at: _allPinViews.index(of: pin)!)
		
		// 3. update all curves as anything incoming no longer links to this item
		updateCurves() // TODO: Could optimize by only redrawing the connected curves
	}
}

// MARK: - Selected Node Functions -
extension GraphView {
	// adds a link to selected nodes
	@objc private func addLinkToSelectedNodes() {
		_selectionHandler?.Selection.forEach({ (node) in
			let link = Manager.makeLink(origin: node.Object)
			NovellaGraph.add(link: link)
			// the rest is handled in the story callbacks
		})
	}
	
	// adds a branch to selected nodes
	@objc private func addBranchToSelectedNodes() {
		_selectionHandler?.Selection.forEach({ (node) in
			let branch = Manager.makeBranch(origin: node.Object)
			NovellaGraph.add(link: branch)
		})
	}
}


// MARK: - NVStoryDelegate -
extension GraphView: NVStoryDelegate {
	func onStoryGraphAddNode(node: NVNode, parent: NVGraph) {
		if parent != self.NovellaGraph {
			return
		}
		
		let pos: CGPoint
		if node.Position == CGPoint.zero {
			pos = NSMakePoint(visibleRect.midX, visibleRect.midY)
		} else {
			pos = node.Position
		}
		
		switch node {
		case is NVDialog:
			makeDialogNode(nvDialog: node as! NVDialog, at: pos)
			
		case is NVDelivery:
			makeDeliveryNode(nvDelivery: node as! NVDelivery, at: pos)
			
		case is NVContext:
			makeContextNode(nvContext: node as! NVContext, at: pos)
			
		default:
			print("Added node to GraphView but it is not yet handled: \(node)")
		}
	}
	
	func onStoryGraphAddGraph(graph: NVGraph, parent: NVGraph) {
		if parent == self.NovellaGraph {
			if self.getNodeFrom(object: graph, includeParentGraphs: false) != nil {
				print("Tried to add graph as a Node but it already exists!")
				return
			}
			
			let pos: CGPoint
			if graph.Position == CGPoint.zero {
				pos = NSMakePoint(visibleRect.midX, visibleRect.midY)
			} else {
				pos = graph.Position
			}
			makeGraphNode(nvGraph: graph, at: pos)
		}
	}
	
	func onStoryGraphAddLink(link: NVBaseLink, parent: NVGraph) {
		if parent != self.NovellaGraph {
			return
		}
		
		guard let originView = getNodeFrom(object: link.Origin, includeParentGraphs: false) else {
			print("Tried to add link to graph but its origin node wasn't in the GraphView yet.")
			return
		}
		
		switch link {
		case is NVLink:
			originView.addOutput(pin: makePinViewLink(baseLink: link as! NVLink, forNode: originView))
			
		case is NVBranch:
			originView.addOutput(pin: makePinViewBranch(baseLink: link as! NVBranch, forNode: originView))
			
		case is NVSwitch:
			originView.addOutput(pin: makePinViewSwitch(baseLink: link as! NVSwitch, forNode: originView))
			
		default:
			print("GraphView::onStoryGraphAddLink() encountered unsupported link (\(link)).")
			break
		}
	}
	
	func onStoryGraphSetEntry(entry: NVObject, graph: NVGraph) {
		if graph != self.NovellaGraph {
			return
		}
		
		for x in _allNodes {
			x.updateEntryLabel()
		}
	}
	
	func onStoryTrashObject(object: NVObject) {
		switch object {
		case is NVDialog:
			fallthrough
		case is NVDelivery:
			fallthrough
		case is NVContext:
			fallthrough
		case is NVGraph:
			if let lv = getNodeFrom(object: object, includeParentGraphs: false) {
				lv.Trashed = true
			}
			
		case is NVBaseLink:
			if let pin = _allPinViews.first(where: {$0.BaseLink == object}) {
				pin.TrashMode = true
			}
			
		default:
			print("Trashed unsupported item: \(object)")
		}
	}
	func onStoryUntrashObject(object: NVObject) {
		for linkTo in _document.Manager.getLinksTo(object) {
			if let pin = _allPinViews.first(where: {$0.BaseLink == linkTo}) {
				pin.TrashMode = false
			}
		}
		
		switch object {
		case is NVDialog:
			fallthrough
		case is NVDelivery:
			fallthrough
		case is NVContext:
			fallthrough
		case is NVGraph:
			if let lv = getNodeFrom(object: object, includeParentGraphs: false) {
				lv.Trashed = false
			}
			
		case is NVBaseLink:
			if let pin = _allPinViews.first(where: {$0.BaseLink == object}) {
				pin.TrashMode = false
			}
			
		default:
			print("Trashed unsupported item: \(object)")
		}
	}
	
	func onStoryDeleteLink(link: NVBaseLink) {
		if let pin = _allPinViews.first(where: {$0.BaseLink == link}) {
			deletePinView(pin: pin)
		}
	}
	func onStoryDeleteNode(node: NVNode) {
		if let node = _allNodes.first(where: {$0.Object == node}) {
			deleteNode(node: node)
		}
	}
	func onStoryDeleteGraph(graph: NVGraph) {
		if let graph = _allNodes.first(where: {$0.Object == graph}) {
			deleteNode(node: graph)
		}
	}
	
	// name and content changes
	func onStoryObjectNameChanged(obj: NVObject, oldName: String, newName: String) {
		_allNodes.first(where: {$0.Object == obj})?.onNameChanged()
	}
	func onStoryDialogContentChanged(content: String, node: NVDialog) {
		_allNodes.first(where: {$0.Object == node})?.onContentChanged()
	}
	func onStoryDeliveryContentChanged(content: String, node: NVDelivery) {
		_allNodes.first(where: {$0.Object == node})?.onContentChanged()
	}
	
	// size changes
	func onStoryNodeSizeChanged(node: NVNode) {
		_allNodes.first(where: {$0.Object == node})?.respondToSizeChange()
	}
}
