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
		_outlineView.reloadData()
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
			
		case let asLink as NVLink:
//			(view as? NSTableCellView)?.textField?.stringValue = "(\(asLink.Origin.Label)) -> (\(asSequenceLink.Destination?.Label ?? "nil"))"
			(view as? NSTableCellView)?.textField?.stringValue = "(FIXME) -> (FIXME)"
			(view as? NSTableCellView)?.imageView?.image = _linkIcon ?? NSImage(named: NSImage.cautionName)
			
		case let asEvent as NVEvent:
			(view as? NSTableCellView)?.textField?.stringValue = asEvent.Label
			
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
			return (asGroup.Sequences.count + asGroup.Links.count + asGroup.Groups.count) // ordering is mirrored below
			
		case let asSequence as NVSequence:
			return (asSequence.Events.count + asSequence.Links.count) // ordering is mirrored below
			
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
			
			if index < (asGroup.Links.count + offset) {
				return asGroup.Links[index - offset]
			}
			offset += asGroup.Links.count
			
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
			
			if index < (asSequence.Links.count + offset) {
				return asSequence.Links[index - offset]
			}
			offset += asSequence.Links.count
			
			fatalError()
			
		default:
			fatalError()
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case let asGroup as NVGroup:
			return (asGroup.Sequences.count + asGroup.Links.count + asGroup.Groups.count) > 0
			
		case let asSequence as NVSequence:
			return (asSequence.Events.count + asSequence.Links.count) > 0
			
		default:
			return false
		}
	}
}

// MARK: - NVStoryObserver -
extension OutlinerViewController: NVStoryObserver {
	// MARK: - Groups
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
	
	func nvGroupDidAddLink(story: NVStory, group: NVGroup, link: NVLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveLink(story: NVStory, group: NVGroup, link: NVLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	// MARK: - Sequences
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence) {
		_outlineView.reloadItem(sequence)
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asLink = item as? NVLink, asLink.Origin.UUID == sequence.UUID || asLink.Destination?.UUID == sequence.UUID {
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
	
	func nvSequenceDidAddLink(story: NVStory, sequence: NVSequence, link: NVLink) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidRemoveLink(story: NVStory, sequence: NVSequence, link: NVLink) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	// MARK: - Events
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
		_outlineView.reloadItem(event)
		
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asLink = item as? NVLink, asLink.Origin.UUID == event.UUID || asLink.Destination?.UUID == event.UUID {
				_outlineView.reloadItem(item)
			}
		}
	}
	
	// MARK: - Links
	func nvLinkDestinationChanged(story: NVStory, link: NVLink) {
		_outlineView.reloadItem(link)
	}
}
