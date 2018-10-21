//
//  Canvas.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class Canvas: NSView {
	static let DEFAULT_SIZE: CGFloat = 600000.0
	
	// MARK: - Variables
	private let _background: CanvasBG
	private let _marquee: CanvasMarquee
	private var _allObjects: [CanvasObject]
	private var _allLinks: [Link]
	private var _panGesture: NSPanGestureRecognizer?
	private var _benches: [CanvasObject:Bench<NSView>]
	private var _canvasContextMenu = NSMenu()
	private var _rmbPanLocation = CGPoint.zero
	private var _rmbInitialMag: CGFloat = 0.0
	private var _rmbInitialLoc = CGPoint.zero
	
	// MARK: - Properties
	private(set) var Doc: Document
	private(set) var Graph: NVGraph
	private(set) var Selection: CanvasSelection?
	
	// MARK: - Initialization
	init(doc: Document, graph: NVGraph) {
		self.Doc = doc
		self.Graph = graph
		self.Selection = nil
		let initialFrame = NSMakeRect(0, 0, Canvas.DEFAULT_SIZE, Canvas.DEFAULT_SIZE)
		self._background = CanvasBG(frame: initialFrame)
		self._marquee = CanvasMarquee(frame: initialFrame)
		self._allObjects = []
		self._allLinks = []
		self._benches = [:]
		self._panGesture = nil
		super.init(frame: initialFrame)
		
		// setup layers
		wantsLayer = true
		
		// pan gesture
		_panGesture = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onPan))
		_panGesture?.buttonMask = 0x1 // "primary button"
		addGestureRecognizer(_panGesture!)
		
		// rmb pan gesture
		let rmbPanGesture = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onRmbPan))
		rmbPanGesture.buttonMask = 0x2
		addGestureRecognizer(rmbPanGesture)
		
		// context click gesture
		let canvasContextGesture = NSClickGestureRecognizer(target: self, action: #selector(Canvas.onContext))
		canvasContextGesture.buttonMask = 0x2 // "secondary click"
		canvasContextGesture.numberOfClicksRequired = 1
		addGestureRecognizer(canvasContextGesture)
		
		// canvas context menu setup
		_canvasContextMenu.addItem(withTitle: "Save to image...", action: #selector(Canvas.onContextSaveImage), keyEquivalent: "")
		
		// selection handler
		Selection = CanvasSelection(canvas: self)
		
		// setup for this graph
		setupForGraph(graph)
		
		// setup story delegate
		doc.Story.addDelegate(self)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Canvas::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	func setupForGraph(_ graph: NVGraph) {
		// remove selection
		Selection?.select([], append: false)
		// clear all objects
		_allObjects = []
		// clear all links
		_allLinks = []
		// clear all benches
		_benches = [:]
		// remove all subviews
		subviews.removeAll()
		
		// store graph
		self.Graph = graph
		
		// add background and marquee
		addSubview(_background)
		addSubview(_marquee)
		
		//
		// create existing graph contents
		//
		// nodes (without their links)
		for curr in graph.Nodes {
			switch curr {
			case let asDialog as NVDialog:
				makeDialog(at: Doc.Positions[curr.ID] ?? CGPoint.zero, nvNode: asDialog)
			case let asDelivery as NVDelivery:
				makeDelivery(at: Doc.Positions[curr.ID] ?? CGPoint.zero, nvNode: asDelivery)
			default:
				NVLog.log("Encountered unhandled node type while creating Canvas.", level: .warning)
			}
		}
		// branches (without their links)
		for curr in graph.Branches {
			makeBranch(at: Doc.Positions[curr.ID] ?? CGPoint.zero, nvBranch: curr)
		}
		// switches (without their links)
		for curr in graph.Switches {
			makeSwitch(at: Doc.Positions[curr.ID] ?? CGPoint.zero, nvSwitch: curr)
		}
		// links
		for curr in graph.Links {
			if let node = canvasObjectFor(nvLinkable: curr.Origin) as? CanvasNode {
				benchFor(object: node)?.add(makeLink(origin: curr.Origin, nvLink: curr))
			} else {
				NVLog.log("Tried to add Link but couldn't find the origin's CanvasObject counterpart.", level: .warning)
			}
		}
		// redraw all
		_allObjects.forEach{$0.redraw()}
	}
	
	override func mouseDown(with event: NSEvent) {
		Selection?.select([], append: false)
	}
	
	func canvasObjectFor(nvLinkable: NVLinkable) -> CanvasObject? {
		for curr in _allObjects {
			switch curr {
			case let asCanvasBranch as CanvasBranch:
				if asCanvasBranch.Branch.ID == nvLinkable.ID {
					return curr
				}
				
			case let asCanvasSwitch as CanvasSwitch:
				if asCanvasSwitch.Switch.ID == nvLinkable.ID {
					return curr
				}
				
			case let asCanvasNode as CanvasNode:
				if asCanvasNode.Node.ID == nvLinkable.ID {
					return curr
				}
				
			default:
				break
			}
		}
		return nil
	}
	
	func allTransfersTo(nvLinkable: NVLinkable) -> [Transfer] {
		var result: [Transfer] = []
		
		// check all links (covers all nodes, but not branches or switches, as they are using Transfer directly)
		_allLinks.forEach { (link) in
			if let canvasTransfer = link.TheTransfer, canvasTransfer.TheTransfer.Destination?.ID == nvLinkable.ID {
				result.append(canvasTransfer)
			}
		}
		
		// check all branches
		(_allObjects.filter{$0 is CanvasBranch} as! [CanvasBranch]).forEach { (branch) in
			if branch.TrueTransfer.TheTransfer.Destination?.ID == nvLinkable.ID {
				result.append(branch.TrueTransfer)
			}
			if branch.FalseTransfer.TheTransfer.Destination?.ID == nvLinkable.ID {
				result.append(branch.FalseTransfer)
			}
		}
		
		// check all switches
		(_allObjects.filter{$0 is CanvasSwitch} as! [CanvasSwitch]).forEach { (swtch) in
			// todo: switch stores everything in the bench only... maybe i can do this for the other ones to keep privates private?
			(benchFor(object: swtch)?.Items as? [SwitchOption])?.forEach{ (option) in
				if option.TheTransfer.TheTransfer.Destination?.ID == nvLinkable.ID {
					result.append(option.TheTransfer)
				}
			}
		}
		
		return result
	}
	
	func objectAt(point: CGPoint) -> CanvasObject? {
		for curr in _allObjects {
			if curr.hitTest(point) != curr {
				continue
			}
			return curr
		}
		return nil
	}
	private func objectIn(obj: CanvasObject, rect: NSRect) -> Bool {
		return NSIntersectsRect(obj.frame, rect)
	}
	private func allObjectsIn(rect: NSRect) -> [CanvasObject] {
		var objs: [CanvasObject] = []
		_allObjects.forEach({ (curr) in
			if objectIn(obj: curr, rect: _marquee.Region) {
				objs.append(curr)
			}
		})
		return objs
	}
	
	func benchFor(object: CanvasObject) -> Bench<NSView>? {
		return _benches.keys.contains(object) ? _benches[object] : nil
	}
	
	// MARK: Gesture Callbacks
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			if !_marquee.InMarquee {
				_marquee.Origin = gesture.location(in: self)
				_marquee.InMarquee = true
			}
			
		case .changed:
			if _marquee.InMarquee {
				_marquee.End = gesture.location(in: self)
				
				// handle un/priming of nodes out/in the marquee region
				let objectsInMarquee = allObjectsIn(rect: _marquee.Region)
				for curr in _allObjects {
					if curr.CurrentState == .selected {
						continue
					}
					objectsInMarquee.contains(curr) ? curr.prime() : curr.normal()
				}
			}
			
		case .cancelled, .ended:
			if _marquee.InMarquee {
				// select whatever was inside the marquee (appending if shift pressed)
				let append = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
				Selection?.select(allObjectsIn(rect: _marquee.Region), append: append)
				
				_marquee.InMarquee = false
			}
			
		default:
			break
		}
	}
	@objc private func onRmbPan(gesture: NSPanGestureRecognizer) {
		guard let scrollView = superview?.superview as? NSScrollView else {
			print("Attempted to RMB pan Canvas but it was not correctly embedded within an NSScrollView (NSScrollView->NSClipView->Canvas).")
			return
		}
		
		switch gesture.state {
		case .began:
			_rmbPanLocation = gesture.location(in: scrollView)
			_rmbInitialLoc = _rmbPanLocation
			_rmbInitialMag = scrollView.magnification
			
		case .changed:
			let curr = gesture.location(in: scrollView)
			

			
			if NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false {
				let diff = (curr - _rmbInitialLoc)
				let dist = (diff.x - diff.y) * 0.001
				scrollView.magnification = _rmbInitialMag + dist
			} else {
				let panSpeed: CGFloat = 0.5
				var diff = (curr - _rmbPanLocation) * panSpeed
				diff.x *= scrollView.isFlipped ? -1.0 : 1.0
				diff.y *= scrollView.isFlipped ? 1.0 : -1.0
				let center = visibleRect.origin + diff
				scrollView.contentView.scroll(to: center)
				scrollView.reflectScrolledClipView(scrollView.contentView)
			}
			
			_rmbPanLocation = curr
			
		default:
			break
		}
	}
	@objc private func onContext(gesture: NSClickGestureRecognizer) {
		NSMenu.popUpContextMenu(_canvasContextMenu, with: NSApp.currentEvent!, for: self)
	}
	
	// MARK: Canvas Context Callbacks
	@objc private func onContextSaveImage() {
		let rep = self.bitmapImageRepForCachingDisplay(in: visibleRect)!
		self.cacheDisplay(in: visibleRect, to: rep)
		
		let sp = NSSavePanel()
		sp.allowedFileTypes = ["png"]
		if sp.runModal() != NSApplication.ModalResponse.OK {
			return
		}
		let finalData = rep.representation(using: .png, properties: [:])
		do{ try finalData?.write(to: sp.url!) } catch {
			print("Failed to write screenshot to disk.")
		}
	}
	
	// MARK: External Creation
	@discardableResult func makeDialog(at: CGPoint) -> CanvasDialog {
		let dialog = makeDialog(at: at, nvNode: nil)
		Graph.add(node: dialog.Node)
		return dialog
	}
	@discardableResult func makeDelivery(at: CGPoint) -> CanvasDelivery {
		let delivery = makeDelivery(at: at, nvNode: nil)
		Graph.add(node: delivery.Node)
		return delivery
	}
	@discardableResult func makeBranch(at: CGPoint) -> CanvasBranch {
		let branch = makeBranch(at: at, nvBranch: nil)
		Graph.add(branch: branch.Branch)
		return branch
	}
	@discardableResult func makeSwitch(at: CGPoint) -> CanvasSwitch {
		let swtch = makeSwitch(at: at, nvSwitch: nil)
		Graph.add(swtch: swtch.Switch)
		return swtch
	}
	// MARK: Internal Creation
	@discardableResult private func makeDialog(at: CGPoint, nvNode: NVDialog?) -> CanvasDialog {
		// make bench
		let bench = Bench<NSView>()
		addSubview(bench, positioned: .below, relativeTo: _marquee)
		bench.translatesAutoresizingMaskIntoConstraints = false
		
		let node = CanvasDialog(canvas: self, nvNode: nvNode ?? Doc.Story.makeDialog(), bench: bench)
		_allObjects.append(node)
		addSubview(node, positioned: .below, relativeTo: _marquee)
		var pos = at
		pos.x -= node.frame.width * 0.5
		pos.y -= node.frame.height * 0.5
		node.frame.origin = pos
		
		// linking
		bench.constrainTo(node)
		_benches[node] = bench
		
		return node
	}
	@discardableResult private func makeDelivery(at: CGPoint, nvNode: NVDelivery?) -> CanvasDelivery {
		// make bench
		let bench = Bench<NSView>()
		addSubview(bench, positioned: .below, relativeTo: _marquee)
		bench.translatesAutoresizingMaskIntoConstraints = false
		
		let node = CanvasDelivery(canvas: self, nvNode: nvNode ?? Doc.Story.makeDelivery(), bench: bench)
		_allObjects.append(node)
		addSubview(node, positioned: .below, relativeTo: _marquee)
		var pos = at
		pos.x -= node.frame.width * 0.5
		pos.y -= node.frame.height * 0.5
		node.frame.origin = pos
		
		// linking
		bench.constrainTo(node)
		_benches[node] = bench
		
		return node
	}
	@discardableResult private func makeBranch(at: CGPoint, nvBranch: NVBranch?) -> CanvasBranch {
		// make bench
		let bench = Bench<NSView>()
		addSubview(bench, positioned: .below, relativeTo: _marquee)
		bench.translatesAutoresizingMaskIntoConstraints = false
		
		// make branch
		let branch = CanvasBranch(canvas: self, nvBranch: nvBranch ?? Doc.Story.makeBranch(), bench: bench)
		_allObjects.append(branch)
		addSubview(branch, positioned: .below, relativeTo: _marquee)
		var pos = at
		pos.x -= branch.frame.width * 0.5
		pos.y -= branch.frame.height * 0.5
		branch.frame.origin = pos

		// linking
		bench.constrainTo(branch)
		_benches[branch] = bench
		
		return branch
	}
	@discardableResult private func makeSwitch(at: CGPoint, nvSwitch: NVSwitch?) -> CanvasSwitch {
		// make bench
		let bench = Bench<NSView>()
		addSubview(bench, positioned: .below, relativeTo: _marquee)
		bench.translatesAutoresizingMaskIntoConstraints = false
		
		// make switch
		let swtch = CanvasSwitch(canvas: self, nvSwitch: nvSwitch ?? Doc.Story.makeSwitch(), bench: bench)
		_allObjects.append(swtch)
		addSubview(swtch, positioned: .below, relativeTo: _marquee)
		var pos = at
		pos.x -= swtch.frame.width * 0.5
		pos.y -= swtch.frame.height * 0.5
		swtch.frame.origin = pos
		
		// linking
		bench.constrainTo(swtch)
		_benches[swtch] = bench

		return swtch
	}
	@discardableResult func makeLink(origin: NVLinkable, nvLink: NVLink?) -> Link {
		let link = Link(canvas: self, link: nvLink ?? Doc.Story.makeLink(origin: origin))
		_allLinks.append(link)
		if nvLink == nil { // only add if we're making a new link
			Graph.add(link: link.TheLink)
		}
		return link
	}
}

// MARK: - NVStoryDelegate
extension Canvas: NVStoryDelegate {
	func nvNodeDidRename(node: NVNode) {
		guard let obj = canvasObjectFor(nvLinkable: node) else {
			print("Canvas tried to handle nvNodeDidRename(\(node.ID)) but couldn't find a matching CanvasObject.")
			return
		}
		obj.reloadFromModel()
	}
	func nvDialogContentDidChange(dialog: NVDialog) {
		guard let obj = canvasObjectFor(nvLinkable: dialog) else {
			print("Canvas tried to handle nvDialogContentDidChange(\(dialog.ID)) but couldn't find a matching CanvasObject.")
			return
		}
		obj.reloadFromModel()
	}
	func nvDeliveryContentDidChange(delivery: NVDelivery) {
		guard let obj = canvasObjectFor(nvLinkable: delivery) else {
			print("Canvas tried to handle nvDeliveryContentDidChange(\(delivery.ID)) but couldn't find a matching CanvasObject.")
			return
		}
		obj.reloadFromModel()
	}
	
	// deletion
	func nvStoryDidDeleteLink(link: NVLink) {
		// find link
		if let canvasLink = _allLinks.first(where: {$0.TheLink == link}) {
			// remove from superview
			canvasLink.removeFromSuperview()
			
			// remove from node's board
			(_allObjects.filter{$0 is CanvasNode} as! [CanvasNode]).forEach { (canvasNode) in
				if let bench = benchFor(object: canvasNode), bench.contains(canvasLink) {
					bench.remove(canvasLink)
				}
			}
			
			// remove from all links
			if let idx = _allLinks.firstIndex(of: canvasLink) {
				_allLinks.remove(at: idx)
			}
		}
	}
	func nvStoryDidDeleteNode(node: NVNode) {
		if let canvasNode = canvasObjectFor(nvLinkable: node) as? CanvasNode {
			// get and remove the bench
			if let bench = benchFor(object: canvasNode) {
				bench.removeFromSuperview()
				_benches.removeValue(forKey: canvasNode)
			}
			
			// cache transfers that have a the destination as this node so we can refresh them
			let cachedTransfers = allTransfersTo(nvLinkable: node)
			
			// remove from parent view (canvas)
			canvasNode.removeFromSuperview()
			
			// remove from all nodes
			if let idx = _allObjects.firstIndex(of: canvasNode) {
				_allObjects.remove(at: idx)
			}
			
			// update cached transfers so they redraw properly
			cachedTransfers.forEach{$0.redraw()}
		}
	}
	func nvStoryDidDeleteBranch(branch: NVBranch) {
		if let canvasBranch = canvasObjectFor(nvLinkable: branch) as? CanvasBranch {
			if let bench = benchFor(object: canvasBranch) {
				bench.removeFromSuperview()
				_benches.removeValue(forKey: canvasBranch)
			}
			
			let cachedTransfers = allTransfersTo(nvLinkable: branch)
			
			canvasBranch.removeFromSuperview()
			
			if let idx = _allObjects.firstIndex(of: canvasBranch) {
				_allObjects.remove(at: idx)
			}
			
			cachedTransfers.forEach{$0.redraw()}
		}
	}
	func nvStoryDidDeleteSwitch(swtch: NVSwitch) {
		if let canvasSwitch = canvasObjectFor(nvLinkable: swtch) as? CanvasSwitch {
			if let bench = benchFor(object: canvasSwitch) {
				bench.removeFromSuperview()
				_benches.removeValue(forKey: canvasSwitch)
			}
			
			let cachedTransfers = allTransfersTo(nvLinkable: swtch)
			
			canvasSwitch.removeFromSuperview()
			
			if let idx = _allObjects.firstIndex(of: canvasSwitch) {
				_allObjects.remove(at: idx)
			}
			
			cachedTransfers.forEach{$0.redraw()}
		}
	}
}
