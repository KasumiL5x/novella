//
//  OutlinerViewController.swift
//  novella
//
//  Created by Daniel Green on 12/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class OutlinerViewController: NSViewController {
	@IBOutlet weak private var _outlineView: NSOutlineView!
	
	private var _document: Document? = nil
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	func setup(doc: Document) {
		_document = doc
	}
}

extension OutlinerViewController: NSOutlineViewDelegate {
	// custom row class
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return CustomTableRowView(frame: NSRect.zero)
	}
	
	// color even/odd rows
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = (row % 2 == 0) ? NSColor(named: "NVTableRowEven")! : NSColor(named: "NVTableRowOdd")!
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("OutlinerCell"), owner: self)
		
		switch item {
		case let asGroup as NVGroup:
			(view as? NSTableCellView)?.textField?.stringValue = asGroup.Label
			
		case let asBeat as NVBeat:
			(view as? NSTableCellView)?.textField?.stringValue = asBeat.Label
			
		case let asBeatLink as NVBeatLink:
			(view as? NSTableCellView)?.textField?.stringValue = "(\(asBeatLink.Origin.Label)) -> (\(asBeatLink.Destination?.Label ?? "nil"))"
			
		case let asEvent as NVEvent:
			(view as? NSTableCellView)?.textField?.stringValue = asEvent.Label
			
		case let asEventLink as NVEventLink:
			(view as? NSTableCellView)?.textField?.stringValue = "(\(asEventLink.Origin.Label)) -> (\(asEventLink.Destination?.Label ?? "nil"))"
			
		default:
			(view as? NSTableCellView)?.textField?.stringValue = "UNKNOWN TYPE"
		}
		
		return view
	}
}

extension OutlinerViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil { // nil item is the "first" item in the table
			return _document != nil ? 1 : 0 // if not nil, we will load the MainGroup
		}
		
		switch item {
		case let asGroup as NVGroup:
			return (asGroup.Beats.count + asGroup.BeatLinks.count + asGroup.Groups.count) // ordering is mirrored below
			
		case let asBeat as NVBeat:
			return (asBeat.Events.count + asBeat.EventLinks.count) // ordering is mirrored below
			
		default:
			return 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil { // as mentioned above
			return _document!.Story.MainGroup
		}
		
		// order here matches the above function count order
		switch item {
		case let asGroup as NVGroup:
			if index < asGroup.Beats.count {
				return asGroup.Beats[index]
			}
			var offset = asGroup.Beats.count
			
			if index < (asGroup.BeatLinks.count + offset) {
				return asGroup.BeatLinks[index - offset]
			}
			offset += asGroup.BeatLinks.count
			
			if index < (asGroup.Groups.count + offset) {
				return asGroup.Groups[index - offset]
			}
			offset += asGroup.Groups.count
			
			fatalError()
			
		case let asBeat as NVBeat:
			if index < asBeat.Events.count {
				return asBeat.Events[index]
			}
			var offset = asBeat.Events.count
			
			if index < (asBeat.EventLinks.count + offset) {
				return asBeat.EventLinks[index - offset]
			}
			offset += asBeat.EventLinks.count
			
			fatalError()
			
		default:
			fatalError()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case let asGroup as NVGroup:
			return (asGroup.Beats.count + asGroup.BeatLinks.count + asGroup.Groups.count) > 0
			
		case let asBeat as NVBeat:
			return (asBeat.Events.count + asBeat.EventLinks.count) > 0
			
		default:
			return false
		}
	}
}
