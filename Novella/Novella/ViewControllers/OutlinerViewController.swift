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
	private var _sequenceImage: NSImage?
	private var _eventImage: NSImage?
	private var _returnImage: NSImage?
	
	override func viewDidLoad() {
		_linkIcon = NSImage(named: "NVLink")
		_groupImage = NSImage(named: "NVGroup")
		_sequenceImage = NSImage(named: "NVSequence")
		_eventImage = NSImage(named: "NVEvent")
		_returnImage = NSImage(named: "NVReturn")
		
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
	func labelFor(linkable: NVLinkable?) -> String {
		switch linkable {
		case let grp as NVGroup:
			return grp.Label.isEmpty ? "Unnamed" : grp.Label
			
		case let seq as NVSequence:
			return seq.Label.isEmpty ? "Unnamed" : seq.Label
			
		case let evt as NVEvent:
			return evt.Label.isEmpty ? "Unnamed" : evt.Label
			
		case let hub as NVHub:
			return hub.Label.isEmpty ? "Unnamed" : hub.Label
			
		case let rtrn as NVReturn:
			return rtrn.Label.isEmpty ? "Unnamed" : rtrn.Label
			
		case nil:
			return "nil"
			
		default:
			return "error"
		}
	}
	
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
			(view as? NSTableCellView)?.textField?.stringValue = labelFor(linkable: asGroup)
			(view as? NSTableCellView)?.imageView?.image = _groupImage ?? NSImage(named: NSImage.cautionName)
			
		case let asSequence as NVSequence:
			(view as? NSTableCellView)?.textField?.stringValue = labelFor(linkable: asSequence)
			(view as? NSTableCellView)?.imageView?.image = _sequenceImage ?? NSImage(named: NSImage.cautionName)
			
		case let asLink as NVLink:
			(view as? NSTableCellView)?.textField?.stringValue = "(\(labelFor(linkable: asLink.Origin))) -> (\(labelFor(linkable: asLink.Destination)))"
			(view as? NSTableCellView)?.imageView?.image = _linkIcon ?? NSImage(named: NSImage.cautionName)
			
		case let asEvent as NVEvent:
			(view as? NSTableCellView)?.textField?.stringValue = labelFor(linkable: asEvent)
			(view as? NSTableCellView)?.imageView?.image = _eventImage ?? NSImage(named: NSImage.cautionName)
			
		case let asHub as NVHub:
			(view as? NSTableCellView)?.textField?.stringValue = labelFor(linkable: asHub)
			(view as? NSTableCellView)?.imageView?.image = NSImage(named: NSImage.cautionName)
			
		case let asReturn as NVReturn:
			(view as? NSTableCellView)?.textField?.stringValue = labelFor(linkable: asReturn)
			(view as? NSTableCellView)?.imageView?.image = _returnImage ?? NSImage(named: NSImage.cautionName)
			
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
			return (asGroup.Sequences.count + asGroup.Links.count + asGroup.Groups.count + asGroup.Hubs.count + asGroup.Returns.count) // ordering is mirrored below
			
		case let asSequence as NVSequence:
			return (asSequence.Events.count + asSequence.Links.count + asSequence.Hubs.count + asSequence.Returns.count) // ordering is mirrored below
			
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
			
			if index < (asGroup.Hubs.count + offset) {
				return asGroup.Hubs[index - offset]
			}
			offset += asGroup.Hubs.count
			
			if index < (asGroup.Returns.count + offset) {
				return asGroup.Returns[index - offset]
			}
			offset += asGroup.Returns.count
			
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
			
			if index < (asSequence.Hubs.count + offset) {
				return asSequence.Hubs[index - offset]
			}
			offset += asSequence.Hubs.count
			
			if index < (asSequence.Returns.count + offset) {
				return asSequence.Returns[index - offset]
			}
			offset += asSequence.Returns.count
			
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
	
	func nvGroupDidAddHub(story: NVStory, group: NVGroup, hub: NVHub) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveHub(story: NVStory, group: NVGroup, hub: NVHub) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidAddReturn(story: NVStory, group: NVGroup, rtrn: NVReturn) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveReturn(story: NVStory, group: NVGroup, rtrn: NVReturn) {
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
	
	func nvSequenceDidAddHub(story: NVStory, sequence: NVSequence, hub: NVHub) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidRemoveHub(story: NVStory, sequence: NVSequence, hub: NVHub) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidAddReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn) {
		_outlineView.reloadItem(sequence, reloadChildren: true)
	}
	
	func nvSequenceDidRemoveReturn(story: NVStory, sequence: NVSequence, rtrn: NVReturn) {
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
	
	// MARK: - Hubs
	func nvHubLabelDidChange(story: NVStory, hub: NVHub) {
		_outlineView.reloadItem(hub)
		
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asLink = item as? NVLink, asLink.Origin.UUID == hub.UUID || asLink.Destination?.UUID == hub.UUID {
				_outlineView.reloadItem(item)
			}
		}
	}
	
	// MARK: - Returns
	func nvReturnLabelDidChange(story: NVStory, rtrn: NVReturn) {
		_outlineView.reloadItem(rtrn)
		
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asLink = item as? NVLink, asLink.Origin.UUID == rtrn.UUID || asLink.Destination?.UUID == rtrn.UUID {
				_outlineView.reloadItem(item)
			}
		}
	}
	
	// MARK: - Links
	func nvLinkDestinationChanged(story: NVStory, link: NVLink) {
		_outlineView.reloadItem(link)
	}
}
