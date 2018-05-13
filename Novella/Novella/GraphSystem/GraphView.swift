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
	fileprivate let _nvStory: NVStory
	fileprivate let _bg: GraphBGView
	fileprivate let _undoRedo: UndoRedo
	//
	fileprivate var _allLinkableViews: [LinkableView]
	fileprivate var _allPinViews: [PinView]
	// MARK: Selection
	fileprivate var _marquee: MarqueeView
	fileprivate var _selectedNodes: [LinkableView]
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
	
	// MARK: - - Initialization -
	init(graph: NVGraph, story: NVStory, frameRect: NSRect) {
		self._nvGraph = graph
		self._nvStory = story
		self._bg = GraphBGView(frame: frameRect)
		self._undoRedo = UndoRedo()
		//
		self._allLinkableViews = []
		self._allPinViews = []
		//
		self._marquee = MarqueeView(frame: frameRect)
		self._selectedNodes = []
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
		
		super.init(frame: frameRect)
		
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
		let addMenu = NSMenuItem()
		addMenu.title = "Add..."
		addMenu.submenu = addSubMenu
		_graphViewMenu.addItem(addMenu)
		
		rootFor(graph: _nvGraph)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("GraphView::init(coder) not implemented.")
	}
	
	// MARK: - - Functions -
	// MARK: Setup
	fileprivate func rootFor(graph: NVGraph) {
		// remove existing views
		self.subviews.removeAll()
		
		// add background
		self.addSubview(_bg)
		// add marquee view (must be last; others add after it)
		self.addSubview(_marquee)
		
		// clear undo/redo
		_undoRedo.clear()
		
		// clear existing linkable views
		_allLinkableViews = []
		// clear existing pin views
		_allPinViews = []
		
		
		// load all nodes
		for curr in graph.Nodes {
			switch curr {
			case is NVDialog:
				let node = DialogView(node: curr as! NVDialog, graphView: self)
				_allLinkableViews.append(node)
				self.addSubview(node, positioned: .below, relativeTo: _marquee)
				break
			default:
				print("Not implemented node type \(curr).")
				break
			}
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
	
	// MARK: Updating
	func updateCurves() {
		for child in _allPinViews {
			child.redraw()
		}
	}
	
	// MARK: Gesture Callbacks
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
				let append = NSApp.currentEvent!.modifierFlags.contains(.shift)
				selectNodes(allNodesIn(rect: _marquee.Marquee), append: append)
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
	
	// MARK: Undo/Redo
	func undo(levels: Int=1) {
		_undoRedo.undo(levels: levels)
	}
	func redo(levels: Int=1) {
		_undoRedo.redo(levels: levels)
	}
	
	// MARK: Selection
	fileprivate func selectNodes(_ nodes: [LinkableView], append: Bool) {
		_selectedNodes.forEach({$0.deselect()})
		_selectedNodes = append ? (_selectedNodes + nodes) : nodes
		_selectedNodes.forEach({$0.select()})
	}
	fileprivate func deselectNodes(_ nodes: [LinkableView]) {
		nodes.forEach({
			if _selectedNodes.contains($0) {
				$0.deselect()
				_selectedNodes.remove(at: _selectedNodes.index(of: $0)!)
			}
		})
	}
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
	
	// MARK: Helpers
	func getLinkableViewFrom(linkable: NVLinkable?) -> LinkableView? {
		if nil == linkable {
			return nil
		}
		
		return _allLinkableViews.first(where: {
			return $0.Linkable.UUID == linkable?.UUID
		})
	}
	
	// MARK: From Linkable
	func onClickLinkable(node: LinkableView, gesture: NSGestureRecognizer) {
		let append = NSApp.currentEvent!.modifierFlags.contains(.shift)
		if append {
			if node.IsSelected {
				deselectNodes([node])
			} else {
				selectNodes([node], append: append)
			}
		} else {
			selectNodes([node], append: append)
		}

	}
	func onPanLinkable(node: LinkableView, gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			// if node is not selected but we dragged it, replace selection and then start dragging
			if !node.IsSelected {
				selectNodes([node], append: false)
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
			
			_selectedNodes.forEach({
				let pos = NSMakePoint($0.frame.origin.x + dx, $0.frame.origin.y + dy)
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
	// MARK: Linkable Context Menu
	@objc fileprivate func onLinkableMenuAddLink() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a link to a linkable via context but _contextClickedLinkable was nil.")
			return
		}
		let nvLink = _nvStory.makeLink(origin: clicked.Linkable)
		clicked.addOutput(pin: makePinViewLink(baseLink: nvLink, forNode: clicked))
	}
	@objc fileprivate func onLinkableMenuAddBranch() {
		guard let clicked = _contextClickedLinkable else {
			print("Tried to add a link to a branch via context but _contextClickedLinkable was nil.")
			return
		}
		let nvBranch = _nvStory.makeBranch(origin: clicked.Linkable)
		clicked.addOutput(pin: makePinViewBranch(baseLink: nvBranch, forNode: clicked))
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
	// MARK: PinView Context Menus
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
	
	// MARK: GraphView Context Menu
	@objc fileprivate func onGraphViewMenuAddDialog() {
		// make the actual dialog node
		let nvDialog = _nvStory.makeDialog()
		// add it to this graph
		do { try _nvGraph.add(node: nvDialog) } catch {
			// TODO: Possibly handle this by allowing for a remove(node:) in story which removes it from everything?
			fatalError("Tried to add a new dialog but couldn't add it to this graph.")
		}
		let dlgView = makeDialogView(nvDialog: nvDialog)
		var pos = _lastContextLocation
		pos.x -= dlgView.frame.width/2
		pos.y -= dlgView.frame.height/2
		dlgView.move(to: pos)
	}
}

// MARK: - - Creation -
extension GraphView {
	// MARK: LinkableViews
	@discardableResult
	func makeDialogView(nvDialog: NVDialog) -> DialogView {
		let node = DialogView(node: nvDialog, graphView: self)
		_allLinkableViews.append(node)
		self.addSubview(node, positioned: .below, relativeTo: _marquee)
		return node
	}
	
	// MARK: PinViews
	func makePinViewLink(baseLink: NVLink, forNode: LinkableView) -> PinViewLink {
		let pin = PinViewLink(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		return pin
	}
	func makePinViewBranch(baseLink: NVBranch, forNode: LinkableView) -> PinViewBranch {
		let pin = PinViewBranch(link: baseLink, graphView: self, owner: forNode)
		_allPinViews.append(pin)
		return pin
	}
}
