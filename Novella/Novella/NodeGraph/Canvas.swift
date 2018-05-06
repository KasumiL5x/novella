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
	var _nodesView: NSView
	var _canvasWidgets: [CanvasWidget]
	
	// where curves are stored
	var _curvesView: NSView
	var _curveWidgets: [CurveWidget]
	
	// canvas-wide undo/redo
	let _undoRedo: UndoRedo
	
	override init(frame frameRect: NSRect) {
		_grid = GridView(frame: frameRect)
		
		_nodesView = NSView(frame: frameRect)
		_canvasWidgets = []
		
		_curvesView = NSView(frame: frameRect)
		_curveWidgets = []
		
		_undoRedo = UndoRedo()
		
		super.init(frame: frameRect)
		
		// layers for subviews
		wantsLayer = true
		// add background grid
		self.addSubview(_grid)
		// add nodes view
		self.addSubview(_nodesView)
		// add curves view
		self.addSubview(_curvesView)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Canvas::init(coder) not implemented.")
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
		// remove all nodes
		_nodesView.subviews.removeAll()
		_canvasWidgets = []
		
		// remove all curves
		_curvesView.subviews.removeAll()
		_curveWidgets = []
		
		// clear undo/redo
		_undoRedo.clear()
	}
	
	// MARK: Canvas Widget Creation
	func makeDialogWidget(novellaDialog: Dialog) {
		let widget = DialogWidget(node: novellaDialog, canvas: self)
		_canvasWidgets.append(widget)
		_nodesView.addSubview(widget)
	}
	
	func makeLinkWidget(novellaLink: Link) {
		let widget = LinkWidget(link: novellaLink, canvas: self)
		_curveWidgets.append(widget)
		_curvesView.addSubview(widget)
	}
	
	func makeBranchWidget(novellaBranch: Branch) {
		let widget = BranchWidget(branch: novellaBranch, canvas: self)
		_curveWidgets.append(widget)
		_curvesView.addSubview(widget)
	}
	
	// MARK: Canvas-wide functions
	func moveCanvasWidget(widget: CanvasWidget, from: CGPoint, to: CGPoint) {
		_undoRedo.execute(cmd: MoveCanvasWidgetCmd(widget: widget, from: from, to: to))
	}
	
	// MARK: Convert Novella to Canvas
	func getCanvasWidgetFrom(linkable: Linkable?) -> CanvasWidget? {
		if linkable == nil {
			return nil
		}
		
		let widget = _canvasWidgets.first(where: {
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
		for child in _curvesView.subviews {
			child.layer?.setNeedsDisplay()
		}
	}
}
