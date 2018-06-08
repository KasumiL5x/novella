//
//  GraphTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphTabViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet private weak var _scrollView: NSScrollView!
	@IBOutlet private weak var _toolbarView: NSView!
	
	
	// MARK: - - Variables -
	private var _manager: NVStoryManager?
	private static let GRAPH_SIZE: CGFloat = 600000
	private var _graphView: GraphView?
	//
	private var _graph: NVGraph?
	private var _delegate: GraphViewDelegate?
	//
	private var _firstAppear: Bool = true
	
	// MARK: - - Properties -
	var Graph: GraphView? {
		get{ return _graphView }
	}
	
	// MARK: - - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// if setup was called pre-load...
		if _graph != nil && _delegate != nil {
			configure()
		}
		
		_toolbarView.wantsLayer = true
		_toolbarView.layer?.backgroundColor = NSColor.fromHex("#252525").cgColor
	}
	
	override func viewWillAppear() {
		if _firstAppear {
			centerView()
			_firstAppear = false
		}
	}
	
	fileprivate func configure() {
		_graphView = GraphView(manager: _manager!, graph: _graph!, frameRect: NSMakeRect(0.0, 0.0, GraphTabViewController.GRAPH_SIZE, GraphTabViewController.GRAPH_SIZE))
		_graphView?.Delegate = _delegate
		_scrollView.documentView = _graphView!
	}
	
	func setup(manager: NVStoryManager, graph: NVGraph, delegate: GraphViewDelegate) {
		_manager = manager
		_graph = graph
		_delegate = delegate
		
		// if the view has already loaded...
		if isViewLoaded {
			configure()
		}
	}
	
	func zoomSelected() {
		guard let selectedRect = _graphView?.selectedBounds() else { return }
		if selectedRect != NSRect.zero {
			_scrollView.magnify(toFit: selectedRect)
		}
	}
	
	func centerView() {
		var center = NSMakePoint(_graphView!.bounds.width/2, _graphView!.bounds.height/2)
		center.x -= _graphView!.visibleRect.width/2
		center.y -= _graphView!.visibleRect.height/2
		
		NSAnimationContext.runAnimationGroup({ (context) in
			context.duration = 0.3
			_scrollView.contentView.animator().setBoundsOrigin(center)
		}, completionHandler: {
			self._scrollView.reflectScrolledClipView(self._scrollView.contentView)
		})
	}
	
	fileprivate func centerOfGraph() -> CGPoint {
		let centerSelf = NSMakePoint(self.view.frame.width/2, self.view.frame.height/2)
		return _graphView?.convert(centerSelf, from: self.view) ?? CGPoint.zero
	}
	
	// MARK: - - Interface Callbacks -
	@IBAction func onToolbarDialog(_ sender: NSButton) {
		_graphView?.makeDialog(at: centerOfGraph())
	}
	
	@IBAction func onToolbarDelivery(_ sender: NSButton) {
		_graphView?.makeDelivery(at: centerOfGraph())
	}
	
	@IBAction func onToolbarContext(_ sender: NSButton) {
		_graphView?.makeContext(at: centerOfGraph())
	}
	
	@IBAction func onToolbarGraph(_ sender: NSButton) {
		_graphView?.makeGraph(at: centerOfGraph())
	}
}
