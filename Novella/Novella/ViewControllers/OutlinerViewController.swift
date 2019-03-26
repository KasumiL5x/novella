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
	private var _linkIcon: NSImage?
	private var _groupImage: NSImage?
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		_linkIcon = NSImage(named: "NVLink")
		_groupImage = NSImage(named: "NVGroup")
		
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
	}
	
	func setup(doc: Document) {
		_document = doc
		doc.Story.add(observer: self)
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
			(view as? NSTableCellView)?.imageView?.image = _groupImage ?? NSImage(named: NSImage.cautionName)
			
		case let asSequence as NVSequence:
			(view as? NSTableCellView)?.textField?.stringValue = asSequence.Label
			
		case let asSequenceLink as NVSequenceLink:
			(view as? NSTableCellView)?.textField?.stringValue = "(\(asSequenceLink.Origin.Label)) -> (\(asSequenceLink.Destination?.Label ?? "nil"))"
			(view as? NSTableCellView)?.imageView?.image = _linkIcon ?? NSImage(named: NSImage.cautionName)
			
		case let asEvent as NVEvent:
			(view as? NSTableCellView)?.textField?.stringValue = asEvent.Label
			
		case let asEventLink as NVEventLink:
			(view as? NSTableCellView)?.textField?.stringValue = "(\(asEventLink.Origin.Label)) -> (\(asEventLink.Destination?.Label ?? "nil"))"
			(view as? NSTableCellView)?.imageView?.image = _linkIcon ?? NSImage(named: NSImage.cautionName)
			
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
			return (asGroup.Sequences.count + asGroup.SequenceLinks.count + asGroup.Groups.count) // ordering is mirrored below
			
		case let asSequence as NVSequence:
			return (asSequence.Events.count + asSequence.EventLinks.count) // ordering is mirrored below
			
		default:
			return 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil { // as mentioned above
			return _document!.Story.MainGroup!
		}
		
		// order here matches the above function count order
		switch item {
		case let asGroup as NVGroup:
			if index < asGroup.Sequences.count {
				return asGroup.Sequences[index]
			}
			var offset = asGroup.Sequences.count
			
			if index < (asGroup.SequenceLinks.count + offset) {
				return asGroup.SequenceLinks[index - offset]
			}
			offset += asGroup.SequenceLinks.count
			
			if index < (asGroup.Groups.count + offset) {
				return asGroup.Groups[index - offset]
			}
			offset += asGroup.Groups.count
			
			fatalError()
			
		case let asSequence as NVSequence:
			if index < asSequence.Events.count {
				return asSequence.Events[index]
			}
			var offset = asSequence.Events.count
			
			if index < (asSequence.EventLinks.count + offset) {
				return asSequence.EventLinks[index - offset]
			}
			offset += asSequence.EventLinks.count
			
			fatalError()
			
		default:
			fatalError()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case let asGroup as NVGroup:
			return (asGroup.Sequences.count + asGroup.SequenceLinks.count + asGroup.Groups.count) > 0
			
		case let asSequence as NVSequence:
			return (asSequence.Events.count + asSequence.EventLinks.count) > 0
			
		default:
			return false
		}
	}
}

extension OutlinerViewController: NVStoryObserver {
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		_outlineView.reloadItem(group)
	}
	
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence) {
		_outlineView.reloadItem(sequence)
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asSequenceLink = item as? NVSequenceLink, asSequenceLink.Origin == sequence || asSequenceLink.Destination == sequence {
				_outlineView.reloadItem(item)
			}
		}
	}
	
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
		_outlineView.reloadItem(event)
		
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asEventLink = item as? NVEventLink, asEventLink.Origin == event || asEventLink.Destination == event {
				_outlineView.reloadItem(item)
			}
		}
	}
}
