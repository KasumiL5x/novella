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
	var _marquee: MarqueeView
	var _selectedNodes: [LinkableView]
	// MARK: Gestures
	var _panGesture: NSPanGestureRecognizer?
	// MARK: Linkable Function Variables
	var _lastLinkablePanPos: CGPoint
	
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
		//
		self._lastLinkablePanPos = CGPoint.zero
		
		super.init(frame: frameRect)
		
		self._panGesture = NSPanGestureRecognizer(target: self, action: #selector(GraphView.onPan))
		self._panGesture!.buttonMask = 0x1 // "primary button"
		self.addGestureRecognizer(self._panGesture!)
		
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
	}
	
	// MARK: From PinView
	func onPanPin(pin: PinView, gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			pin.IsDragging = true
			pin.DragPosition = gesture.location(in: pin)
			pin.redraw()
			break
			
		case .changed:
			pin.DragPosition = gesture.location(in: pin)
			pin.redraw()
			break
			
		case .cancelled, .ended:
			pin.IsDragging = false
			pin.redraw()
			break
			
		default:
			print("onPanPin found unexpected gesture state.")
			break
		}
	}
}

// MARK: - - Creation -
extension GraphView {
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
