//
//  MainViewController.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class MenuTableView: NSTableView {
	var rowClickAction: ((NSTableView, NSTableRowView, Int) -> Void)? // target table, clicked row view, clicked row index
	
	override func mouseDown(with event: NSEvent) {
		let local = self.convert(event.locationInWindow, from: nil)
		let index = self.row(at: local)
		
		super.mouseDown(with: event)
		
		if index != -1 {
			let clickedRow = self.rowView(atRow: index, makeIfNecessary: false)!
			rowClickAction?(self, clickedRow, index)
            self.deselectAll(self) // don't want the item to stay selected so deselect it after firing the event
		}
	}
}

class MainViewController: NSViewController, NSTableViewDelegate {
	// MARK: - Outlets
	@IBOutlet weak var _leftToolbar: ColoredView!
	@IBOutlet weak var _sidebarTable: MenuTableView!
	
	// MARK: - Variables
	private var _outlinerGraphVC: OutlinerGraphViewController? = nil
	private var _previewPopover: PreviewPopover = PreviewPopover()
	private var _entitiesWC: EntitiesWindowController? = nil
	private var _variablesWC: VariablesWindowController? = nil
	private var _sidebarItems: [(title: String, icon: NSImage?, action: Selector?)] = [
		(title: "Outliner",  icon: NSImage(named: NSImage.touchBarSidebarTemplateName), action: #selector(MainViewController.onMenuOutliner)),
		(title: "Preview",   icon: NSImage(named: "Play"), action: #selector(MainViewController.onMenuPreview)),
		(title: "Variables", icon: NSImage(named: "Code"), action: #selector(MainViewController.onMenuVariables)),
		(title: "Entities",  icon: NSImage(named: "User"), action: #selector(MainViewController.onMenuEntities)),
		(title: "Dialog",    icon: NSImage(named: "Dialog"), action: #selector(MainViewController.onMenuDialog)),
		(title: "Delivery",  icon: NSImage(named: "Delivery"), action: #selector(MainViewController.onMenuDelivery)),
		(title: "Branch",    icon: NSImage(named: "Branch"), action: #selector(MainViewController.onMenuBranch)),
		(title: "Switch",    icon: NSImage(named: "Switch"), action: #selector(MainViewController.onMenuSwitch)),
	]
	
	// MARK: - Menu Callbacks
	@objc private func onMenuOutliner(sender: NSTableRowView) {
		_outlinerGraphVC?.toggleLeft()
	}
	@objc private func onMenuPreview(sender: NSTableRowView) {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		guard let graph = _outlinerGraphVC?.GraphVC?.MainCanvas?.Graph else {
			return
		}
		_previewPopover.show(forView: sender, at: .maxX)
		_previewPopover.setup(doc: doc, graph: graph)
	}
	@objc private func onMenuVariables(sender: NSTableRowView) {
		guard let doc = view.window?.windowController?.document as? Document, let wc = _variablesWC else {
			return
		}
		wc.showWindow(nil)
		(wc.contentViewController as? VariablesViewController)?.Doc = doc
	}
	@objc private func onMenuEntities(sender: NSTableRowView) {
		guard let doc = view.window?.windowController?.document as? Document, let wc = _entitiesWC else {
			return
		}
		wc.showWindow(nil)
		(wc.contentViewController as? EntitiesViewController)?.Doc = doc
	}
	@objc private func onMenuDialog(sender: NSTableRowView) {
		_outlinerGraphVC?.GraphVC?.MainCanvas?.makeDialog(at: _outlinerGraphVC!.GraphVC!.centerOfCanvas())
	}
	@objc private func onMenuDelivery(sender: NSTableRowView) {
		_outlinerGraphVC?.GraphVC?.MainCanvas?.makeDelivery(at: _outlinerGraphVC!.GraphVC!.centerOfCanvas())
	}
	@objc private func onMenuBranch(sender: NSTableRowView) {
		_outlinerGraphVC?.GraphVC?.MainCanvas?.makeBranch(at: _outlinerGraphVC!.GraphVC!.centerOfCanvas())
	}
	@objc private func onMenuSwitch(sender: NSTableRowView) {
		_outlinerGraphVC?.GraphVC?.MainCanvas?.makeSwitch(at: _outlinerGraphVC!.GraphVC!.centerOfCanvas())
	}
	
	
	// MARK: - Controller Callbacks
	override func viewWillAppear() {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		
		// setup graph
		_outlinerGraphVC?.GraphVC?.setup(doc: doc)
		
		// setup outliner
		_outlinerGraphVC?.OutlinerVC?.Doc = doc
		_outlinerGraphVC?.OutlinerVC?.onItemSelected = { (item, parent) in
			guard let canvas = self._outlinerGraphVC?.GraphVC?.MainCanvas else {
				return
			}
			
			// load the item's graph if it is not already loaded
			if canvas.Graph != parent {
				canvas.setupForGraph(parent)
			}
			
			// note: disabling this for now as i want it to either work both ways (without a cycle issue) or just one way (i.e., clear selection when one changes)
//			// try to select the item (todo: allow multi-select at some point)
//			if let linkable = item as? NVLinkable, let canvasObject = canvas.canvasObjectFor(nvLinkable: linkable) {
//				canvas.Selection?.select(canvasObject, append: false)
//			}
		}
		
		// setup sidebar menu
		_sidebarTable.delegate = self
		_sidebarTable.usesStaticContents = true
		for i in 0..<_sidebarItems.count {
			_sidebarTable.insertRows(at: [i], withAnimation: .slideRight)
		}
		_sidebarTable.rowClickAction = { (table, row, index) in
			let menuItem = self._sidebarItems[index]
			if let action = menuItem.action {
				NSApplication.shared.sendAction(action, to: self, from: row)
			}
		}
		
		// entities window setup
		let entitiesStoryboard = NSStoryboard(name: "Entities", bundle: nil)
		_entitiesWC = entitiesStoryboard.instantiateController(withIdentifier: "EntitiesWindow") as? EntitiesWindowController
		
		// variables window setup
		let variablesStoryboard = NSStoryboard(name: "Variables", bundle: nil)
		_variablesWC = variablesStoryboard.instantiateController(withIdentifier: "VariablesWindow") as? VariablesWindowController
	}
	
	
	// MARK: - Left Toolbar Callbacks
	@IBAction func onLeftToolbarExpand(_ sender: NSButton) {
		let con = _leftToolbar.constraints.first(where: {$0.firstAttribute == .width})
		
		let minSize: CGFloat = 55.0
		let maxSize: CGFloat = 150.0
		NSAnimationContext.runAnimationGroup { (ctx) in
			ctx.duration = 0.15
			con?.animator().constant = (con!.constant <= minSize) ? maxSize : minSize
		}
	}
	
	// MARK: Segue
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "OutlinerGraph" {
			_outlinerGraphVC = segue.destinationController as? OutlinerGraphViewController
		}
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSView?
		
		view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MenuCell"), owner: self) as? NSTableCellView
		
		let menuItem = _sidebarItems[row]
		
		(view as? NSTableCellView)?.textField?.stringValue = menuItem.title
		(view as? NSTableCellView)?.imageView?.image = menuItem.icon ?? NSImage(named: NSImage.cautionName)
		
		return view
	}
}
