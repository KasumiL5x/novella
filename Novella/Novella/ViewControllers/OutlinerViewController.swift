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
		doc.Story.addDelegate(self)
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

extension OutlinerViewController: NVStoryDelegate {
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidMakeBeat(story: NVStory, beat: NVBeat) {
	}
	
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidMakeBeatLink(story: NVStory, link: NVBeatLink) {
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
	}
	
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidDeleteBeat(story: NVStory, beat: NVBeat) {
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidDeleteBeatLink(story: NVStory, link: NVBeatLink) {
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		_outlineView.reloadItem(group)
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup) {
	}
	
	func nvGroupDidAddBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidAddBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvGroupDidRemoveBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
		_outlineView.reloadItem(group, reloadChildren: true)
	}
	
	func nvBeatLabelDidChange(story: NVStory, beat: NVBeat) {
		_outlineView.reloadItem(beat)
		for i in 0..<_outlineView.numberOfRows {
			let item = _outlineView.item(atRow: i)
			if let asBeatLink = item as? NVBeatLink, asBeatLink.Origin == beat || asBeatLink.Destination == beat {
				_outlineView.reloadItem(item)
			}
		}
	}
	
	func nvBeatParallelDidChange(story: NVStory, beat: NVBeat) {
	}
	
	func nvBeatEntryDidChange(story: NVStory, beat: NVBeat) {
	}
	
	func nvBeatDidAddEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		_outlineView.reloadItem(beat, reloadChildren: true)
	}
	
	func nvBeatDidRemoveEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
		_outlineView.reloadItem(beat, reloadChildren: true)
	}
	
	func nvBeatDidAddEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		_outlineView.reloadItem(beat, reloadChildren: true)
	}
	
	func nvBeatDidRemoveEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
		_outlineView.reloadItem(beat, reloadChildren: true)
	}
	
	func nvDNBeatTangibilityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatFunctionalityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatClarityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatDeliveryDidChange(story: NVStory, beat: NVDiscoverableBeat) {
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
	
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
	}
	
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableInitialValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvBeatLinkDestinationDidChange(story: NVStory, link: NVBeatLink) {
	}
	
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink) {
	}
	
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
	}
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
	}
}
