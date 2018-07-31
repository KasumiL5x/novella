//
//  GraphEditorViewController.swift
//  Novella
//
//  Created by Daniel Green on 21/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class GraphEditorViewController: NSViewController {
	// MARK: - - Outlets -
	@IBOutlet private weak var _scrollView: NSScrollView!
	@IBOutlet private weak var _toolbarView: NSView!
	
	
	// MARK: - - Variables -
	private var _document: NovellaDocument?
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
		_toolbarView.layer?.backgroundColor = NSColor.fromHex("#fafafa").cgColor
	}
	
	override func viewDidAppear() {
		if _firstAppear {
			if !zoomAll() {
				centerView(animated: false)
			}
			_firstAppear = false
		}
	}
	
	private func configure() {
		_graphView = GraphView(doc: _document!, graph: _graph!, frameRect: NSMakeRect(0.0, 0.0, GraphEditorViewController.GRAPH_SIZE, GraphEditorViewController.GRAPH_SIZE))
		_graphView?.Delegate = _delegate
		_scrollView.documentView = _graphView!
		
		_scrollView.scrollsDynamically = false
		_scrollView.contentView.copiesOnScroll = false
	}
	
	func setup(doc: NovellaDocument, graph: NVGraph, delegate: GraphViewDelegate) {
		self._document = doc
		_graph = graph
		_delegate = delegate
		
		// if the view has already loaded...
		if isViewLoaded {
			configure()
		}
	}
	
	func zoomSelected() -> Bool {
		if _graphView == nil {
			return false
		}
		
		guard let selectedRect = _graphView?.selectedBounds() else { return false }
		if selectedRect != NSRect.zero {
			_scrollView.magnify(toFit: selectedRect)
			return true
		}
		return false
	}
	func zoomAll() -> Bool {
		if _graphView == nil {
			return false
		}
		
		guard let allRect = _graphView?.contentBounds() else { return false }
		if allRect != NSRect.zero {
			_scrollView.magnify(toFit: allRect)
			return true
		}
		return false
	}
	func zoom(to: CGFloat) {
		if _graphView == nil {
			return
		}
		
		_scrollView.magnification = to
	}
	
	func centerView(animated: Bool) {
		if _graphView == nil {
			return
		}
		
		var center = NSMakePoint(_graphView!.bounds.width/2, _graphView!.bounds.height/2)
		center.x -= _graphView!.visibleRect.width/2
		center.y -= _graphView!.visibleRect.height/2
		
		if !animated {
			_scrollView.contentView.setBoundsOrigin(center)
		} else {
			NSAnimationContext.runAnimationGroup({ (context) in
				context.duration = 0.3
				_scrollView.contentView.animator().setBoundsOrigin(center)
			}, completionHandler: {
				self._scrollView.reflectScrolledClipView(self._scrollView.contentView)
			})
		}
	}
	
	private func centerOfGraph() -> CGPoint {
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